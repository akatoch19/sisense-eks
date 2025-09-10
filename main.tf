#########################################################
# Terraform main entry point for Sisense on AWS EKS
# Corrected for provider aliasing and dependency cycles
#########################################################

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
# EKS Cluster
#########################################################
module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  k8s_version         = var.k8s_version
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnet_ids
  enable_oidc_provider = var.enable_oidc_provider
  env                  = var.env
}

#########################################################
# Kubernetes / Helm providers (aliased)
#########################################################
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  alias = "eks"
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

#########################################################
# IAM Roles (Node + EBS CSI) - after cluster OIDC
#########################################################
module "iam" {
  source            = "./modules/iam"
  env               = var.env
  cluster_name      = var.cluster_name
  account_id        = data.aws_caller_identity.current.account_id
  oidc_provider_arn = module.eks.oidc_provider_arn
}

#########################################################
# Node Groups
#########################################################
module "nodegroups" {
  source = "./modules/nodegroups"

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  cluster_name   = module.eks.cluster_name
  node_iam_role  = module.iam.eks_node_role_arn
  instance_types = var.instance_types
  disk_size      = var.disk_size
  min_size       = var.min_size
  max_size       = var.max_size
  desired_size   = var.desired_size
  extra_userdata = var.extra_userdata
  namespace      = var.namespace
  subnet_ids     = module.vpc.private_subnet_ids
}

#########################################################
# Storage (FSx Lustre + EBS CSI IAM Roles)
#########################################################
module "storage" {
  source               = "./modules/storage"
  fsx_storage_capacity = var.fsx_storage_capacity
  private_subnets      = module.vpc.private_subnet_ids
  fsx_sg_id            = module.sg.fsx_sg_id
  env                  = var.env
  depends_on           = [module.nodegroups]
}

#########################################################
# Kubernetes Addons (EBS CSI driver, Cluster Autoscaler)
#########################################################
module "addons" {
  source              = "./modules/addons"
  cluster_name        = module.eks.cluster_name
  ebs_service_account = "ebs-csi-controller-sa"
  ebs_role_arn        = module.iam.ebs_csi_role_arn
  depends_on          = [module.storage]
}
