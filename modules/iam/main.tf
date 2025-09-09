#########################################################
# IAM module for EKS nodes and EBS CSI driver (GovCloud-ready)
#########################################################

# Detect partition (aws or aws-us-gov)
data "aws_partition" "current" {}

############################
# Node IAM Role
############################
resource "aws_iam_role" "eks_node_role" {
  name = "${var.env}-eks-node-role"

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
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role = aws_iam_role.eks_node_role.name

  policy_arn = var.use_custom_cni_policy ?
    aws_iam_policy.custom_eks_cni_policy.arn :
    (
      data.aws_partition.current.partition == "aws-us-gov" ?
      var.eks_cni_govcloud_arn :
      "arn:aws:iam::aws:policy/AmazonEKSCNIPolicy"
    )
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
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

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:DescribeVolumes",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ],
        Resource = "arn:${data.aws_partition.current.partition}:ec2:::volume/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_attach" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = aws_iam_policy.ebs_csi_policy.arn
}

############################
# Optional Custom CNI Policy for GovCloud
############################
resource "aws_iam_policy" "custom_eks_cni_policy" {
  count       = var.use_custom_cni_policy ? 1 : 0
  name        = "${var.env}-eks-cni-policy"
  description = "Custom EKS CNI Policy for GovCloud"
  policy      = file("${path.module}/policies/eks_cni_policy.json")
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
