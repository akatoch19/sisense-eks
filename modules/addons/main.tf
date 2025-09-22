
############################################################
# EBS CSI as a managed EKS Add-on (no Kubernetes API needed)
############################################################
terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      configuration_aliases = [helm.eks]
    }
  }
}
data "aws_partition" "current" {}
locals {
  eks_oidc_issuer          = var.eks_oidc_issuer
  eks_oidc_issuer_noscheme = replace(local.eks_oidc_issuer, "https://", "")
}

data "aws_iam_policy_document" "ebs_csi_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
 
    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_provider_arn]
    }
 
    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}
resource "aws_iam_role" "ebs_csi_irsa" {
  name               = "${var.cluster_name}-ebs-csi-irsa"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_trust.json
  tags = var.tags
}
 
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_irsa.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
 
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  # Optional: pin version
  # addon_version          = "v1.29.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_irsa.arn
  resolve_conflicts_on_update = "OVERWRITE"
  tags = var.tags
}
##########################################
# Cluster autoscaler (optional Helm chart)
###########################################
resource "helm_release" "cluster_autoscaler" {
  provider   = helm.eks
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
 chart      = "cluster-autoscaler"
 namespace  = "kube-system"
 version    = "9.24.0"
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
 }
}
#########################################
# aws-fsx-csi-driver
#########################################
resource "helm_release" "fsx_csi" {
  provider   = helm.eks
  count = var.fsx_irsa_role_arn == null ? 0 : 1
  name       = "aws-fsx-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-fsx-csi-driver"
  chart      = "aws-fsx-csi-driver"
  namespace  = "kube-system"
  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }
  set {
    name  = "controller.serviceAccount.name"
    value = "fsx-csi-controller-sa"
  }
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.fsx_irsa_role_arn
  }
}