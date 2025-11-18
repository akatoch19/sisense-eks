########################################
# AWS Provider
########################################
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = "arn:${var.aws_partition}:iam::${var.aws_account_id}:role/${var.target_deployment_role}"
  }

  default_tags {
    tags = merge(
      var.tags,
      {
        Project     = "sisense-staging-eks"
        Environment = var.env
      }
    )
  }
}

# Get caller identity for debugging
data "aws_caller_identity" "current" {}

########################################
# EKS Cluster Data Sources
########################################
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

########################################
# Locals for OIDC (optional)
########################################
locals {
  eks_oidc_provider_url = module.eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
}

########################################
# Kubernetes Provider
########################################
provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token

  
}

########################################
# Helm Provider
########################################
provider "helm" {
  alias = "eks"

  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  
  }
}

