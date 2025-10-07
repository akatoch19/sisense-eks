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
# Security Groups
#########################################################
module "sg" {
  source              = "./modules/security-groups"
  vpc_id              = var.vpc_id
  fsx_sg_ingress_port = 988
  env                 = var.env
}

#########################################################
# EKS Cluster
#########################################################
module "eks" {
  source               = "./modules/eks"
  cluster_name         = var.cluster_name
  k8s_version          = var.k8s_version
  vpc_id               = var.vpc_id
  private_subnets      = var.private_subnets
  enable_oidc_provider = var.enable_oidc_provider
  jumphost_role_arn    = module.jumphost.role_arn
  env                  = var.env
}

#########################################################
# Node Groups (Application, Query, Build)
#########################################################
module "nodegroups" {
  source         = "./modules/nodegroups"
  cluster_name   = module.eks.cluster_name
  node_iam_role  = module.iam.eks_node_role_arn
  #instance_types = var.instance_types
  disk_size      = var.disk_size
  min_size       = var.min_size
  max_size       = var.max_size
  desired_size   = var.desired_size
  extra_userdata = var.extra_userdata
  namespace      = var.namespace
  subnet_ids     = var.private_subnets
  ami_type       = var.ami_type
  node_role_arn = module.iam.eks_node_role_arn
  #launch_template = module.lt.launch_template
  #depends_on = [
  #  module.lt
  #]
}

#########################################################
# Storage (FSx Lustre + EBS CSI IAM Roles)
#########################################################
module "storage" {
  source               = "./modules/storage"
  fsx_storage_capacity = var.fsx_storage_capacity
  private_subnets      = var.private_subnets
  fsx_sg_id            = module.sg.fsx_sg_id
  env                  = var.env
}
#######################################################
# Kubernetes Addons (EBS CSI driver, Cluster Autoscaler)
#########################################################
module "addons" {
 source                = "./modules/addons"
  cluster_name          = module.eks.cluster_name
  ebs_service_account   = "ebs-csi-controller-sa"
  ebs_role_arn          = module.iam.ebs_csi_role_arn
  eks_oidc_provider_url = local.eks_oidc_provider_url
  eks_oidc_provider_arn = local.eks_oidc_provider_arn
  eks_oidc_issuer       = module.eks.cluster_oidc_issuer_url
  #fsx_irsa_role_arn     = module.iam.fsx_irsa_role_arn
  depends_on = [
     module.eks,module.iam, module.nodegroups ]
  env                   = var.env
  providers = {
   helm.eks = helm.eks
  }

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
  source                = "./modules/iam"
  env                   = var.env
  cluster_name          = var.cluster_name
  account_id            = data.aws_caller_identity.current.account_id
  oidc_provider_arn     = module.eks.oidc_provider_arn
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
}
########################################################
# jumphost
########################################################
module "jumphost" {
  source            = "./modules/jumphost"
  vpc_id            = var.vpc_id
  subnet_id     = element(var.private_subnets, var.jumphost_subnet_index)
  cluster_name      = var.cluster_name
  cluster_sg_id     = module.eks.cluster_security_group_id
  region            = var.aws_region
  instance_type     = "t3.micro"
  env               = var.env
}
######################################################
# alb
########################################################

module "alb_controller" {
  source            = "./modules/alb_controller"
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  depends_on = [
    module.eks,
    module.iam,
    module.nodegroups
  ]

  providers = {
    kubernetes.eks = kubernetes.eks
    helm.eks       = helm.eks
  }
}

#########################################################

RDS

##########################################################

module "rds_mssql" {
  source = "./modules/rds_mssql"

  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnets
  db_name          = "sisense"
  instance_class   = "db.m6i.xlarge"
  username         = "adminuser"
  password         = var.db_password
  ad_directory_id  = var.ad_directory_id
  eks_node_sg_ids  = [for ng in module.eks.node_groups : ng.security_group_id]
  common_tags      = var.common_tags
}



#module "lt" {
 # source = "./modules/launch_template"

  # pass in variables the LT module needs (like disk_size, ami_id, etc.)
  # example:

#}
