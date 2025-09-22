#########################################################
# IAM module for EKS nodes and EBS CSI driver
#########################################################
############################
# Node IAM Role
############################
resource "aws_iam_role" "eks_node_role" {
  name = "${var.env}-eks-node-role"
  tags = var.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}
# Attach managed policies
data "aws_partition" "current" {}
 
locals {
  aws_managed = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
}
 
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "${local.aws_managed}/AmazonEKSWorkerNodePolicy"
}
 
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "${local.aws_managed}/AmazonEKS_CNI_Policy"
}
 
resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "${local.aws_managed}/AmazonEC2ContainerRegistryReadOnly"
}
 
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "${local.aws_managed}/CloudWatchAgentServerPolicy"
}
 

############################
#  EBS CSI IAM Role
############################
data "aws_iam_policy_document" "ebs_trust" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name               = "${var.env}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_trust.json
}

resource "aws_iam_policy" "ebs_csi_policy" {
  name        = "${var.env}-ebs-csi-policy"
  description = "EBS CSI policy for ${var.cluster_name}"
  policy      = file("${path.module}/ebs_iam_policy.json") # see below
}

resource "aws_iam_role_policy_attachment" "ebs_attach" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = aws_iam_policy.ebs_csi_policy.arn
}

############################
# Outputs
############################
output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "ebs_csi_role_arn" {
  value = aws_iam_role.ebs_csi_role.arn
}

