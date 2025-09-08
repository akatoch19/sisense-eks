# Part 1 – VPC
module "vpc" {
  source = "./modules/vpc"
  env    = var.env
}

# Part 2 – Security Groups
module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
}

# Part 3 – EKS Cluster
module "eks" {
  source         = "./modules/eks"
  cluster_name   = "${var.env}-eks"
  k8s_version    = var.k8s_version
  vpc_subnets    = module.vpc.private_subnets
  oidc_provider  = true
}

# Part 4 – Managed Node Groups
module "nodegroups" {
  source          = "./modules/nodegroups"
  cluster_name    = module.eks.cluster_name
  node_iam_role   = module.eks.node_role_arn
  instance_types  = ["m5.4xlarge"] # customize per Sisense req
  min_size        = 3
  max_size        = 6
  desired_size    = 4
  extra_userdata  = file("userdata/bootstrap.sh")
}

# Part 5 – Storage (FSx + EBS CSI)
module "storage" {
  source        = "./modules/storage"
  cluster_name  = module.eks.cluster_name
  vpc_subnets   = module.vpc.private_subnets
  security_group_ids = [module.security_groups.fsx_sg_id]
}

# Part 6 – Addons (EBS CSI, Autoscaler, etc.)
module "addons" {
  source       = "./modules/addons"
  cluster_name = module.eks.cluster_name
  oidc_arn     = module.eks.oidc_provider_arn
}

# Part 7 – DNS / Route53
module "dns" {
  source = "./modules/dns"
  zone_name = "sisense.example.com"
}
