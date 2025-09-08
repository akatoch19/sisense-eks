module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version
  subnets         = var.private_subnets
  vpc_id          = var.vpc_id
  enable_irsa     = var.enable_oidc_provider
  manage_aws_auth = true

  tags = {
    Environment = var.env
    Project     = "Sisense-EKS"
  }
}

output "cluster_name" { value = module.eks.cluster_id }
output "oidc_provider_arn" { value = module.eks.oidc_provider_arn }
