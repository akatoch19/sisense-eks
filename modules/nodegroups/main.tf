locals {
  node_groups = {
    sisense-application = {
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      disk_size_gib     = 400
      node_role_arn  = var.node_role_arn
      instance_types = ["m6i.2xlarge"]
      capacity_type = "ON_DEMAND"
      labels = {
        role                     = "application"
        node-sisense-Application = "true"
      }
      name_tag = "sisense-application"
      #launch_template = var.launch_template
      
    }

    sisense-query = {
      desired_size   = 1
      min_size       = 1
      max_size       = 1
      instance_types = ["r6i.2xlarge"]
      disk_size_gib     = 400
      node_role_arn  = var.node_role_arn
      capacity_type = "ON_DEMAND"
      labels = {
        role                     = "query"
        node-sisense-Query       = "true"
      }
      name_tag = "sisense-query"
      #launch_template = var.launch_template
    }

    sisense-build = {
      desired_size   = 1
      min_size       = 1
      max_size       = 1
      disk_size_gib     = 400
      instance_types = ["m6i.2xlarge"]
      node_role_arn  = var.node_role_arn
      capacity_type  = "ON_DEMAND" 
      labels  = { 
        role         =         "build" 
        node-sisense-Build = "true"
        }
        name_tag = "sisense-build"

        #launch_template = var.launch_template
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
  min_size       = each.value.min_size
  max_size       = each.value.max_size
  instance_types = each.value.instance_types
  #disk_size_gib     = each.value.disk_size_gib
  labels         = each.value.labels
  capacity_type  = each.value.capacity_type
  create_launch_template = false
  #use_custom_launch_template = false
  #pre_bootstrap_user_data = var.extra_userdata
  launch_template_id      = aws_launch_template.ng[each.key].id
  launch_template_version = aws_launch_template.ng[each.key].latest_version
  
  tags = merge(
  var.tags,
  {
    role = lookup(var.tags, "role", each.key)
    Name = lookup(var.tags, "Name", "${var.cluster_name}-${each.key}")
  }
)
}