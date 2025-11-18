locals {
  # Short aliases for each node group’s settings coming from shared.tfvars
  app = var.node_groups["sisense-application"]
  qry = var.node_groups["sisense-query"]
  bld = var.node_groups["sisense-build"]
  node_groups = {
    sisense-application = {
      desired_size   = local.app.desired_size
      min_size       = local.app.min_size
      max_size       = local.app.max_size
      instance_types = local.app.instance_types
      node_role_arn = var.node_role_arn
      labels = {
        role                     = "application"
        node-sisense-Application = "true"
      }
      name_tag = "sisense-application"
    }

    sisense-query = {
      desired_size   = local.qry.desired_size
      min_size       = local.qry.min_size
      max_size       = local.qry.max_size
      instance_types = local.qry.instance_types
      node_role_arn = var.node_role_arn
      labels = {
        role                  = "query"
        node-sisense-Query    = "true"
      }
      name_tag = "sisense-query"
    }
    sisense-build = {
      desired_size   = local.bld.desired_size
      min_size       = local.bld.min_size
      max_size       = local.bld.max_size
      instance_types = local.bld.instance_types
      node_role_arn = var.node_role_arn
      labels = {
        role                 = "build"
        node-sisense-Build   = "true"
      }
      name_tag = "sisense-build"
    }
  }
}
 
module "nodegroups" {
 source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.31.0"
  iam_role_arn = var.node_role_arn  
  cluster_service_cidr = var.cluster_service_cidr
  desired_size   = each.value.desired_size
  for_each       = local.node_groups
  cluster_name   = var.cluster_name
  subnet_ids     = var.subnet_ids
  name           = each.key
  min_size       = each.value.min_size
  max_size       = each.value.max_size
  instance_types = each.value.instance_types
  #disk_size      = each.value.disk_size
  labels         = each.value.labels
  #capacity_type  = each.value.capacity_type
  create_launch_template = false
  launch_template_id      = aws_launch_template.ng[each.key].id
  launch_template_version = aws_launch_template.ng[each.key].latest_version
  #remote_access = {
  # ec2_ssh_key = aws_key_pair.eks_nodes.key_name
  #}
 
  tags = merge(
  var.tags,
  {
   role = lookup(var.tags, "role", each.key)
   Name = "${var.cluster_name}-${each.key}"
   "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
   "k8s.io/cluster-autoscaler/enabled" = "true"
  }
  )
 
}
