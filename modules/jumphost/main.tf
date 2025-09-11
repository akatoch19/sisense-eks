############################
# Pick a private subnet
############################
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
 
  filter {
    name   = "tag:${var.private_subnet_tag_key}"
    values = [var.private_subnet_tag_value]
  }
}
 
resource "random_shuffle" "private_subnet" {
  input        = data.aws_subnets.private.ids
  result_count = 1
}
 
############################
# Security Group (egress-only; inbound via SSM)
############################
resource "aws_security_group" "jumphost_sg" {
  name        = "${var.env}-jumphost-sg"
  description = "Security group for EKS jumphost"
  vpc_id      = var.vpc_id
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "${var.env}-jumphost-sg"
  }
}

resource "aws_security_group_rule" "eks_api_from_jumphost" {
  description              = "Jumphost"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = var.cluster_sg_id
  source_security_group_id = aws_security_group.jumphost_sg.id
}
 


 # Instance Profile for EC2
resource "aws_iam_instance_profile" "jumphost" {
  name = "${var.env}-eks-jumphost-instance-profile"
  role = aws_iam_role.jumphost_role.name
}
 
# Attach the custom policy (and EKS DescribeCluster)
resource "aws_iam_role_policy_attachment" "jumphost__attach" {
  role       = aws_iam_role.jumphost_role.name
  policy_arn = aws_iam_policy.jumphost_custom.arn
}
 
# Attach minimal EKS permissions (needed for kubeconfig/token)
resource "aws_iam_role_policy_attachment" "jumphost_eks_describe_attach" {
  role       = aws_iam_role.jumphost_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEKSClusterPolicy"
}
############################
# IAM Role + Instance Profile
############################
resource "aws_iam_role" "jumphost_role" {
  name = "${var.env}-eks-jumphost-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
 # 1) Define your custom policy
resource "aws_iam_policy" "jumphost_custom" {
  name        = "${var.env}-eks-jumphost-custom"
  description = "Custom policy for jumphost (SSM/ECR/S3/etc.)"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "eks:ListClusters",
        "eks:DescribeCluste",
        "ssm:ListInstanceAssociations",
        "ssm:GetParameter",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceInformation",
        "ssm:PutComplianceItems",
        "ssm:DescribeDocument",
        "ssm:PutConfigurePackageResult",
        "ssm:GetManifest",
        "ssm:GetParameters",
        "ssm:PutInventory",
        "ssm:ListAssociations",
        "ssm:UpdateInstanceAssociationStatus",
        "ssm:GetDocument",
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
        "ssmmessages:CreateControlChannel",
        "eks:*",
        "ecr:BatchGetImage",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ec2:DescribeTags",
        "ec2messages:AcknowledgeMessage",
        "ec2messages:SendReply",
        "ec2messages:GetEndpoint",
        "ec2messages:GetMessages",
        "ec2messages:DeleteMessage",
        "ec2messages:FailMessage",
        "acm:ExportCertificate",
        "logs:PutLogEvents",
        "logs:CreateLogStream",
        "dynamodb:UpdateItem",
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListAllMyBuckets",
        "application-autoscaling:DescribeScalableTargets",
        "application-autoscaling:RegisterScalableTarget"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
 
# 2) Attach it to your existing role
resource "aws_iam_role_policy_attachment" "jumphost_custom_attach" {
  role       = aws_iam_role.jumphost_role.name
  policy_arn = aws_iam_policy.jumphost_custom.arn
}
 



resource "aws_iam_role_policy_attachment" "jumphost_eks_access" {
  role       = aws_iam_role.jumphost_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEKSClusterPolicy"
}
 
resource "aws_iam_role_policy_attachment" "jumphost_ssm_access" {
  role       = aws_iam_role.jumphost_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "jumphost_instance_profile" {
  name = "${var.env}-jumphost-profile"
  role = aws_iam_role.jumphost_role.name

}


############################
# EC2 Jumphost in private subnet
############################

data "aws_ssm_parameter" "al2023_x86" {
  name   = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}
resource "aws_instance" "jumphost" {
  ami                    = data.aws_ssm_parameter.al2023_x86.value
  instance_type          = var.instance_type
  subnet_id              = element(var.private_subnet_ids, 0)
  associate_public_ip_address = false
 iam_instance_profile = var.iam_instance_profile_name != null && var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : aws_iam_instance_profile.jumphost_instance_profile.name
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jumphost_sg.id]

 
  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail
              yum -y update
              # kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x kubectl && mv kubectl /usr/local/bin/
              # AWS CLI
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip -q awscliv2.zip && ./aws/install
              # Helm
              curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
              EOF
 
  tags = {
    Name = "${var.env}-eks-jumphost"
  }
}
output "security_group_id" {
  value = aws_security_group.jumphost_sg.id
}

output "role_arn" {
  value = aws_iam_role.jumphost_role.arn
}