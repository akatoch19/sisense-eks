module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets
  enable_irsa     = var.enable_oidc_provider

  # New way to handle AWS Auth
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  # -------------------------------
  # Optional KMS key for secrets encryption
  # -------------------------------
  cluster_encryption_config = var.kms_key_id == null ? null : {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_id
  }

  # -------------------------------
  # Control plane logging
  # -------------------------------
  cluster_enabled_log_types = []

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
