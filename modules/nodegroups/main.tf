locals {
  node_groups = {
    sisense-application = {
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      instance_types = var.instance_types
      disk_size      = var.disk_size
      node_role_arn  = var.node_iam_role
      labels         = { role = "application" }
    }

    sisense-query = {
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      instance_types = var.instance_types
      disk_size      = var.disk_size
      node_role_arn  = var.node_iam_role
      labels         = { role = "query" }
    }

    sisense-build = {
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      instance_types = var.instance_types
      disk_size      = var.disk_size
      node_role_arn  = var.node_iam_role
      labels         = { role = "build" }
    }
  }
}

module "nodegroups" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.0.0"
  for_each = local.node_groups

  cluster_name   = var.cluster_name
  subnet_ids     = var.subnet_ids

  name           = each.key
  desired_size   = each.value.desired_size
  min_size       = each.value.min_size
  max_size       = each.value.max_size
  instance_types = each.value.instance_types
  disk_size      = each.value.disk_size
  labels         = each.value.labels
}