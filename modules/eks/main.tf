module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_irsa = true

  eks_managed_node_groups = {
    app = {
      instance_types = ["m5.4xlarge"]
      desired_size   = 3
      min_size       = 2
      max_size       = 6
      labels = {
        role = "application"
      }
      disk_size = 400
    }

    query = {
      instance_types = ["r5.4xlarge"]
      desired_size   = 2
      min_size       = 1
      max_size       = 4
      labels = {
        role = "query"
      }
      disk_size = 400
    }

    build = {
      instance_types = ["c5.4xlarge"]
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      labels = {
        role = "build"
      }
      disk_size = 400
    }
  }

  tags = {
    Environment = var.env
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_sg" {
  value = module.eks.cluster_security_group_id
}

output "oidc_provider" {
  value = module.eks.oidc_provider
}
