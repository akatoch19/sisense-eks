module "vpc" {
  source = "./modules/vpc"
  env    = var.env_name
}

module "eks" {
  source       = "./modules/eks"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
  cluster_name = "${var.env_name}-sisense-eks"
  eks_version  = var.eks_version
}

module "irsa" {
  source        = "./modules/irsa"
  cluster_name  = module.eks.cluster_name
  oidc_provider = module.eks.oidc_provider
}

module "addons" {
  source       = "./modules/addons"
  cluster_name = module.eks.cluster_name
  env          = var.env_name
  base_domain  = var.base_domain
  irsa_roles   = module.irsa.roles
}


module "fsx" {
  source     = "./modules/fsx"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  capacity   = var.fsx_storage_capacity
}

module "dns" {
  source      = "./modules/dns"
  env         = var.env_name
  cluster_sg  = module.eks.cluster_sg
}

module "jumphost" {
  source    = "./modules/jumphost"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]
}
