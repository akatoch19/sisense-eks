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
  vpc_id              = module.vpc.vpc_id
  fsx_sg_ingress_port = 988
  env                 = var.env
  private_subnet_ids = data.aws_subnets.account_private_app_subnets.ids
}
#########################################################
# EKS Cluster
#########################################################
module "eks" {
  source               = "./modules/eks"
  cluster_name         = var.cluster_name
  k8s_version          = var.k8s_version
  vpc_id               = data.aws_vpc.account_vpc.id
  private_subnets      = data.aws_subnets.account_private_app_subnets.ids
  enable_irsa          = true
  jumphost_role_arn    = module.jumphost.role_arn
  cloud_admin_entrypoint_role_arn = var.cloud_admin_entrypoint_role_arn
  env                  = var.env
}
#########################################################
# Node Groups (Application, Query, Build)
#########################################################
module "nodegroups" {
  source         = "./modules/nodegroups"
  cluster_name   = module.eks.cluster_name
  node_iam_role  = module.iam.eks_node_role_arn
  namespace      = var.namespace
  subnet_ids = data.aws_subnets.account_private_app_subnets.ids
  ami_type       = var.ami_type
  node_role_arn = module.iam.eks_node_role_arn
  node_groups = var.node_groups
  cluster_service_cidr = var.cluster_service_cidr
  create_cni_policy = true
  depends_on = [
   module.eks ] 
  env = var.env
  tags =var.tags
}
#########################################################
# Storage (FSx Lustre + EBS CSI IAM Roles)
#########################################################
module "storage" {
  source               = "./modules/storage"
  fsx_storage_capacity = var.fsx_storage_capacity
  private_subnets      = data.aws_subnets.account_private_app_subnets.ids
  fsx_sg_id            = module.sg.fsx_sg_id
  fsx_version = var.fsx_version
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
  ebs_csi_irsa_role_arn            = module.iam.ebs_csi_role_arn
  ebs_csi_role_arn      = module.iam.ebs_csi_role_arn
  cluster_autoscaler_irsa_role_arn = module.iam.cluster_autoscaler_irsa_role.arn
  fsx_csi_irsa_role_arn = module.iam.fsx_csi_irsa_role_arn
  enable_ebs_csi = true
  region            = var.aws_region
  depends_on = [
   module.eks,module.iam, module.nodegroups ]          
  env                   = var.env
  providers = {
  kubernetes.eks = kubernetes.eks
   helm.eks       = helm.eks
  }
}
#########################################################
# DNS (Route53)
#########################################################
#module "dns" {
# source       = "./modules/dns"
 #zone_name    = var.zone_name
 #vpc_id       = var.vpc_id
 # env         = var.env
#}
#########################################################
# IAM Roles (Node + EBS CSI)
#########################################################
module "iam" {
  source                   = "./modules/iam"
  env                      = var.env
  cluster_name             = var.cluster_name
  account_id               = data.aws_caller_identity.current.account_id
  eks_oidc_url      = module.eks.cluster_oidc_issuer_url
  oidc_provider_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn = module.eks.oidc_provider_arn
  enable_cluster_autoscaler = true
  enable_ebs_csi_driver = true
}
########################################################
# jumphost
########################################################
module "jumphost" {
  source            = "./modules/jumphost"
  vpc_id            = data.aws_vpc.account_vpc.id
  subnet_id         = data.aws_subnets.account_private_app_subnets.ids[var.jumphost_subnet_index]
  cluster_name      = var.cluster_name
  cluster_sg_id     = module.eks.cluster_security_group_id
  region            = var.aws_region
  instance_type     = var.instance_type
  env               = var.env
}
######################################################
# alb
########################################################
module "alb_controller" {
  source            = "./modules/alb_controller"
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id             = data.aws_vpc.account_vpc.id
  depends_on = [
    module.eks,       
    module.nodegroups 
  ]
  providers = {
  kubernetes.eks = kubernetes.eks
   helm.eks       = helm.eks
  }
}
#########################################################
#RDS
##########################################################
/*module "rds_mssql" {
  source = "./modules/SQL"
 vpc_id          = var.vpc_id
  subnet_ids      = var.db_subnets
  eks_node_sg_ids = []
  db_name         = var.db_name
  username        = var.db_username
  instance_class  = var.db_instance_class
   common_tags = var.tags 
    env               = var.env
  #ad_directory_id = var.ad_directory_id

}*/

