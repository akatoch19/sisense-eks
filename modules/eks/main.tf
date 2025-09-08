module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.0.0"

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version
  subnet_ids      = var.vpc_subnets
  vpc_id          = var.vpc_id
  enable_irsa     = var.oidc_provider
}
