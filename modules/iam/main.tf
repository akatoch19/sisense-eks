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
      Action   = "sts:AssumeRole"
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
 
################################################
# EBS CSI IRSA role
################################################
 
locals {
  eks_oidc_issuer          = var.oidc_provider_url
  eks_oidc_issuer_noscheme = replace(local.eks_oidc_issuer, "https://", "")
}
 
data "aws_iam_policy_document" "ebs_csi_trust" {
  statement {
    effect = "Allow"
 
    actions = ["sts:AssumeRoleWithWebIdentity"]
 
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
 
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_noscheme}:sub"
 
      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa",
      ]
    }
  }
}
 
resource "aws_iam_role" "ebs_csi_irsa" {
  count = var.enable_ebs_csi_driver ? 1 : 0
 
  name = "${var.cluster_name}-ebs-csi-irsa"
 
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_trust.json
 
  tags = var.tags
}
 
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  count = var.enable_ebs_csi_driver ? 1 : 0
 
  role       = aws_iam_role.ebs_csi_irsa[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
 
############################
# Cluster Autoscaler (IRSA)
############################
 
# Inline policy document that the autoscaler needs
data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeImages",
      "eks:DescribeNodegroup",
    ]
    resources = ["*"]
  }
}
############################################
# Trust policy for the ServiceAccount (IRSA)
############################################
data "aws_iam_policy_document" "cluster_autoscaler_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.sa_namespace}:${var.sa_name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}
 
resource "aws_iam_role" "cluster_autoscaler_irsa_role" {
  name               = "${var.cluster_name}-cluster-autoscaler-irsa"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_trust.json
}
resource "aws_iam_policy" "cluster_autoscaler" {
  count  = var.enable_cluster_autoscaler ? 1 : 0
  name   = "${var.env}-cluster-autoscaler-policy"
  policy = data.aws_iam_policy_document.cluster_autoscaler.json
}
 
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count      = var.enable_cluster_autoscaler ? 1 : 0
  role       = aws_iam_role.cluster_autoscaler_irsa_role.name
  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
}
#############################################################
 # Trust stays in Terraform (IRSA binding to fsx-csi-controller-sa)
 ###############################################################
############################
# IAM role for FSx CSI driver (IRSA)
########################################
# FSx CSI IRSA role
#######################################
data "aws_iam_policy_document" "fsx_csi_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
 
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
 
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_noscheme}:sub"
      values = [
        "system:serviceaccount:kube-system:fsx-csi-controller-sa",
      ]
    }
  }
}
 
resource "aws_iam_role" "fsx_csi_irsa" {
  name               = "${var.cluster_name}-fsx-csi-irsa"
  assume_role_policy = data.aws_iam_policy_document.fsx_csi_trust.json
  tags               = var.tags
}
 
resource "aws_iam_role_policy_attachment" "fsx_csi_policy" {
  role       = aws_iam_role.fsx_csi_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonFSxFullAccess"
}
# Outputs
############################
output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

 
output "ebs_csi_role_arn" {
  value = var.enable_ebs_csi_driver ? aws_iam_role.ebs_csi_irsa[0].arn : null
}
 
output "ebs_csi_irsa_role_arn" {
  value = var.enable_ebs_csi_driver ? aws_iam_role.ebs_csi_irsa[0].arn : null
}

 output "eks_node_role_name" {
  value = aws_iam_role.eks_node_role.name
}
 
output "cluster_autoscaler_policy_arn" {
  value       = var.enable_cluster_autoscaler ? aws_iam_policy.cluster_autoscaler[0].arn : null
  description = "ARN of Cluster Autoscaler policy"
}

output "cluster_autoscaler_irsa_role" {
  value = aws_iam_role.cluster_autoscaler_irsa_role
}
output "fsx_csi_irsa_arn" {
  value = aws_iam_role.fsx_csi_irsa.arn
}
output "fsx_csi_irsa_role_arn" {
  description = "IAM role ARN for the FSx CSI controller service account"
  value       = aws_iam_role.fsx_csi_irsa.arn
}

