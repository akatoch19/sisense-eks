#########################################################
# VPC
#########################################################
module "vpc" {
  source          = "./modules/vpc"
  env             = var.env
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

#########################################################
# Security Groups
#########################################################
module "sg" {
  source              = "./modules/security-groups"
  vpc_id              = module.vpc.vpc_id
  fsx_sg_ingress_port = 988
  env                 = var.env
}

#########################################################
# IAM Roles (Node + EBS CSI)
#########################################################
module "iam" {
  source                = "./modules/iam"
  env                   = var.env
  cluster_name          = var.cluster_name
  oidc_provider_arn     = module.eks.oidc_provider_arn
  use_custom_cni_policy = true
  eks_cni_govcloud_arn  = "" # leave blank to use custom CNI
}

#########################################################
# EKS Cluster
#########################################################
module "eks" {
  source               = "./modules/eks"
  cluster_name         = var.cluster_name
  k8s_version          = var.k8s_version
  vpc_id               = module.vpc.vpc_id
  private_subnets      = module.vpc.private_subnets
  enable_oidc_provider = var.enable_oidc_provider
  node_role_arn        = module.iam.eks_node_role_arn
  env                  = var.env

  depends_on = [module.iam]
}

#########################################################
# Node Groups (Application, Query, Build)
#########################################################
module "nodegroups" {
  source         = "./modules/nodegroups"
  cluster_name   = module.eks.cluster_name
  node_iam_role  = module.iam.eks_node_role_arn
  instance_types = var.instance_types
  disk_size      = var.disk_size
  min_size       = var.min_size
  max_size       = var.max_size
  desired_size   = var.desired_size
  extra_userdata = var.extra_userdata
  namespace      = var.namespace
  subnet_ids     = module.vpc.private_subnets

  depends_on = [module.eks]
}

#########################################################
# Storage (FSx Lustre + EBS CSI IAM Roles)
#########################################################
module "storage" {
  source               = "./modules/storage"
  fsx_storage_capacity = var.fsx_storage_capacity
  private_subnets      = module.vpc.private_subnets
  vpc_id               = module.vpc.vpc_id
  vpc_cidr_block       = var.vpc_cidr
  env                  = var.env
  tags                 = { Environment = var.env }

  depends_on = [module.sg]
}

#########################################################
# Kubernetes Addons (EBS CSI driver, Cluster Autoscaler)
#########################################################
module "addons" {
  source              = "./modules/addons"
  cluster_name        = module.eks.cluster_name
  ebs_service_account = "ebs-csi-controller-sa"
  ebs_role_arn        = module.iam.ebs_csi_role_arn

  depends_on = [module.iam]
}

#########################################################
# DNS (Route53)
#########################################################
#module "dns" {
#  source    = "./modules/dns"
#  zone_name = var.zone_name
#  env       = var.env
#}

