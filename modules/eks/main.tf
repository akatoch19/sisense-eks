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
  
  tags = var.tags
}  
# Create access entry for the jumphost role
resource "aws_eks_access_entry" "jumphost" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.jumphost_role_arn
  type          = "STANDARD"
}
# Give cluster-admin to the jumphost role
resource "aws_eks_access_policy_association" "jumphost_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws-us-gov:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.jumphost_role_arn
 
  access_scope {
     type = "cluster"
      }
  depends_on   = [aws_eks_access_entry.jumphost]
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

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}
