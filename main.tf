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
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  k8s_version         = var.k8s_version
  vpc_id              = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
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
  subnet_ids = module.vpc.private_subnet_ids
}

#########################################################
# Storage (FSx Lustre + EBS CSI IAM Roles)
#########################################################
module "storage" {
  source         = "./modules/storage"
  fsx_storage_capacity = var.fsx_storage_capacity
  private_subnets = module.vpc.private_subnet_ids
  fsx_sg_id            = module.sg.fsx_sg_id
  env                  = var.env
}
# Kubernetes Addons (EBS CSI driver, Cluster Autoscaler)
#########################################################
module "addons" {
  source              = "./modules/addons"
  cluster_name        = module.eks.cluster_name
  ebs_service_account = "ebs-csi-controller-sa"
  ebs_role_arn        = module.iam.ebs_csi_role_arn
  eks_oidc_provider_url = local.eks_oidc_provider_url
  eks_oidc_provider_arn = local.eks_oidc_provider_arn
  eks_oidc_issuer = module.eks.cluster_oidc_issuer_url
  env                   = var.env
  providers = {
   kubernetes.eks    = kubernetes.eks
    helm.eks    = helm.eks
 }
  depends_on          = [module.eks, module.nodegroups]
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
########################################################
# jumphost
########################################################
module "jumphost" {
  source = "./modules/jumphost"
  vpc_id             = module.vpc.vpc_id
  subnet_id          = var.private_subnet_id                # if you want a single subnet via var
  private_subnet_ids = module.vpc.private_subnet_ids        # <-- fixed here
  cluster_name  = var.cluster_name
  region        = var.aws_region
  instance_type = "t3.micro"
  key_name      = ""  # optional with SSM

  env  = var.env
}