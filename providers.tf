provider "aws" {
  region  = "us-east-1"
  profile = "staging"

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
data "aws_caller_identity" "current" {}
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

locals {
  eks_oidc_provider_url = module.eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
}

# ---------- Kubernetes provider ----------
provider "kubernetes" {
  alias                  = "eks"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  alias = "eks"
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

