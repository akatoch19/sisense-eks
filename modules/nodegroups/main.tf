module "eks_node_groups" {
  source  = "terraform-aws-modules/eks/aws//modules/node_groups"
  version = "20.0.0"

  cluster_name = var.cluster_name

  node_groups = {
    sisense-app = {
      desired_capacity    = var.desired_size
      min_capacity        = var.min_size
      max_capacity        = var.max_size
      instance_types      = var.instance_types
      disk_size           = var.disk_size
      node_role_arn       = var.node_iam_role
      additional_userdata = templatefile(var.extra_userdata, { ROLE="Application", NAMESPACE=var.namespace })
      labels = { role = "application" }
    }

    sisense-query = {
      desired_capacity    = var.desired_size
      min_capacity        = var.min_size
      max_capacity        = var.max_size
      instance_types      = var.instance_types
      disk_size           = var.disk_size
      node_role_arn       = var.node_iam_role
      additional_userdata = templatefile(var.extra_userdata, { ROLE="Query", NAMESPACE=var.namespace })
      labels = { role = "query" }
    }

    sisense-build = {
      desired_capacity    = 1
      min_capacity        = 1
      max_capacity        = 2
      instance_types      = var.instance_types
      disk_size           = var.disk_size
      node_role_arn       = var.node_iam_role
      additional_userdata = templatefile(var.extra_userdata, { ROLE="Build", NAMESPACE=var.namespace })
      labels = { role = "build" }
    }
  }
}
