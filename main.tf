data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  cluster_name    = var.cluster_name
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  aws_region      = var.aws_region
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  cluster_name          = module.eks.cluster_name
  oidc_provider_arn     = module.eks.oidc_provider_arn
  oidc_provider_url     = module.eks.oidc_provider_url
  environment           = var.environment
  account_id            = data.aws_caller_identity.current.account_id
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  cluster_name          = module.eks.cluster_name
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  node_security_group_id = module.eks.node_security_group_id
  environment           = var.environment
  fsx_security_group_id = module.vpc.fsx_security_group_id
}

# Sisense Module
module "sisense" {
  source = "./modules/sisense"

  cluster_name                  = module.eks.cluster_name
  cluster_endpoint              = module.eks.cluster_endpoint
  cluster_certificate_authority = module.eks.cluster_certificate_authority_data
  environment                   = var.environment
  sisense_license_key           = var.sisense_license_key
  sisense_domain                = var.sisense_domain
  namespace                     = var.namespace
  fsx_filesystem_id             = module.storage.fsx_filesystem_id
  ebs_csi_driver_role_arn       = module.iam.ebs_csi_driver_role_arn
  node_iam_instance_profile     = module.eks.node_iam_instance_profile
}

# DNS Module
module "dns" {
  source = "./modules/dns"

  cluster_name    = var.cluster_name
  environment     = var.environment
  sisense_domain  = var.sisense_domain
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
}
