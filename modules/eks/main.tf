module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets
  enable_irsa     = var.enable_oidc_provider
 
  # New way to handle AWS Auth
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
 
  tags = {
    Environment = var.env
    Project     = "Sisense-EKS"
  }
}
 
output "cluster_name" {
  value = module.eks.cluster_id
}
 
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
