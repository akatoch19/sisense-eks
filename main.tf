#########################################################
# Terraform main entry point for Sisense on AWS EKS
# Integrates:
# - VPC, Subnets, IGW, Routes
# - Security Groups
# - EKS Cluster + OIDC
# - Node Groups with bootstrap/userdata
# - FSx Lustre + EBS CSI
# - Kubernetes Addons (EBS CSI driver, Cluster Autoscaler)
# - DNS (Route53)
#########################################################

#########################################################
# VPC
#########################################################
module "vpc" {
  source       = "./modules/vpc"
  env          = var.env
  vpc_cidr     = var.vpc_cidr
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
# EKS Cluster
#########################################################
module "eks" {
<<<<<<< HEAD
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  k8s_version         = var.k8s_version
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnets
=======
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  k8s_version         = var.k8s_version
  vpc_id              = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
>>>>>>> 28f018a6abee44e21ab34cfe7ba30ed4fe15f9cf
  enable_oidc_provider = var.enable_oidc_provider
  env =var.env
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
<<<<<<< HEAD
  subnet_ids     = module.vpc.private_subnets
=======
  subnet_ids = module.vpc.private_subnet_ids
>>>>>>> 28f018a6abee44e21ab34cfe7ba30ed4fe15f9cf
}

#########################################################
# Storage (FSx Lustre + EBS CSI IAM Roles)
#########################################################
module "storage" {
  source         = "./modules/storage"
  fsx_storage_capacity = var.fsx_storage_capacity
<<<<<<< HEAD
  private_subnets      = module.vpc.private_subnets
  fsx_sg_id            = module.sg.fsx_sg_id
=======
  private_subnets = module.vpc.private_subnet_ids
  fsx_sg_id            = module.sg.fsx_sg_id
>>>>>>> 28f018a6abee44e21ab34cfe7ba30ed4fe15f9cf
  env                  = var.env
<<<<<<< HEAD
=======

>>>>>>> 28f018a6abee44e21ab34cfe7ba30ed4fe15f9cf
}
# Kubernetes Addons (EBS CSI driver, Cluster Autoscaler)
#########################################################
module "addons" {
  source              = "./modules/addons"
  cluster_name        = module.eks.cluster_name
  ebs_service_account = "ebs-csi-controller-sa"
  ebs_role_arn        = module.iam.ebs_csi_role_arn
<<<<<<< HEAD
  depends_on          = [module.eks, module.nodegroups]
=======
   providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
  depends_on          = [module.eks, module.nodegroups]
>>>>>>> 28f018a6abee44e21ab34cfe7ba30ed4fe15f9cf
}

#########################################################
# DNS (Route53)
#########################################################
#module "dns" {
#  source    = "./modules/dns"
#  zone_name = var.zone_name
#  env       = var.env
#}

#########################################################
# IAM Roles (Node + EBS CSI)
#########################################################
module "iam" {
  source           = "./modules/iam"
  env              = var.env
  cluster_name     = var.cluster_name
  account_id       = data.aws_caller_identity.current.account_id
  oidc_provider_arn = module.eks.oidc_provider_arn
}