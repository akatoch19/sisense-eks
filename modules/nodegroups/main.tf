module "nodegroups" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.0.0"

  cluster_name = module.eks.cluster_id
  subnet_ids   = var.subnet_ids

  node_groups = {
    sisense-app = {
      desired_capacity = var.desired_size
      min_capacity     = var.min_size
      max_capacity     = var.max_size
      instance_types   = var.instance_types
      disk_size        = var.disk_size
      node_role_arn    = var.node_iam_role
      labels           = { role = "application" }
    }

    sisense-query = {
      desired_capacity = var.desired_size
      min_capacity     = var.min_size
      max_capacity     = var.max_size
      instance_types   = var.instance_types
      disk_size        = var.disk_size
      node_role_arn    = var.node_iam_role
      labels           = { role = "query" }
    }

    sisense-build = {
      desired_capacity = 1
      min_capacity     = 1
      max_capacity     = 2
      instance_types   = var.instance_types
      disk_size        = var.disk_size
      node_role_arn    = var.node_iam_role
      labels           = { role = "build" }
    }
  }
}
