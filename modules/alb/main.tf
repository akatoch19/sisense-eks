
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      configuration_aliases = [kubernetes.eks]
    }
    helm = {
      source = "hashicorp/helm"
      configuration_aliases = [helm.eks]
    }
  }
}
##############################################
# Get EKS cluster details (to fetch OIDC URL)
##############################################
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}
###############################################
#helm_release aws_load_balancer_controller
###############################################
resource "helm_release" "aws_load_balancer_controller" {
 provider   = helm.eks
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.9.0" 
  namespace  = "default"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.aws_region
      vpcId       = var.vpc_id
      serviceAccount = {
        create = false
        name   = "aws-load-balancer-controller"
      }
    })
  ]
  set {
    name  = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }

  depends_on = [kubernetes_service_account.aws_load_balancer_controller]
}

##########################################################
# Load IAM policy JSON from file (restricted AWS version)
###########################################################
resource "aws_iam_policy" "alb_controller" {
  name        = "${var.cluster_name}-alb-controller"
  description = "Policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/iam_policy.json")
}
###############################################
# IAM role for ALB Controller (IRSA)
#################################################
resource "aws_iam_role" "alb_controller" {
  name               = "${var.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_assume.json
}

data "aws_iam_policy_document" "alb_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}
######################################################
# Service account with IRSA
#######################################################
resource "kubernetes_service_account" "aws_load_balancer_controller" {
   provider = kubernetes.eks
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}
