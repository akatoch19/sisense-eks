provider "aws" {
  region = var.aws_region
  profile = "sisense"
}

provider "helm" {
  alias = "eks"
 
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
# Extract the OIDC issuer URL from the EKS cluster
locals {
  eks_oidc_provider_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}
 
# Data source to look up IAM OIDC provider (removes "https://")
data "aws_iam_openid_connect_provider" "eks" {
  url = local.eks_oidc_provider_url
}
 
# Store its ARN in locals
locals {
  eks_oidc_provider_arn = data.aws_iam_openid_connect_provider.eks.arn
}
 
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}
 
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
 
data "aws_eks_cluster" "this" {
  name = "sisense-eks"
}
 