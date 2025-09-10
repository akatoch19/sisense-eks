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
    Project     = "Sisense-dev-EKS"
  }
}
 
output "cluster_name" {
  value = var.cluster_name
}
 
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
output "cluster_id" {
  value = module.eks.cluster_id
}
output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
 
output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}
 
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}