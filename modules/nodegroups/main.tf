locals {
  node_groups = {
    sisense-application = {
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      disk_size      = var.disk_size
      node_role_arn  = var.node_role_arn
      instance_types = ["m6i.2xlarge"]
      capacity_type = "ON_DEMAND"
      labels = {
        role                     = "application"
        node-sisense-Application = "true"
      }
      #launch_template = var.launch_template
      
    }

    sisense-query = {
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      instance_types = ["r6i.2xlarge"]
      disk_size      = var.disk_size
      node_role_arn  = var.node_role_arn
      capacity_type = "ON_DEMAND"
      labels = {
        role                     = "query"
        node-sisense-Query       = "true"
      }
      #launch_template = var.launch_template
    }

    sisense-build = {
      desired_size   = 1
      min_size       = 1
      max_size       = 1
      instance_types = ["m6i.2xlarge"]
      disk_size      = var.disk_size
      node_role_arn  = var.node_role_arn
      capacity_type  = "ON_DEMAND" 
      labels  = { 
        role         =         "build" 
        node-sisense-Build = "true"
        }

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
  desired_size   = each.value.desired_size
  min_size       = each.value.min_size
  max_size       = each.value.max_size
  instance_types = each.value.instance_types
  disk_size      = each.value.disk_size
  labels         = each.value.labels
  capacity_type  = each.value.capacity_type
  #launch_template_id      = each.value.launch_template.id
  #launch_template_version = "$Latest"

 tags = { 
  cst_environment                   = "dev"
  cst_backup_policy                 = "none" 
  cst_product_line                  = "foundation" 
  cst_tenant                        = "foundation" 
  cst_cost_center                   = "infrastructure"
  cst_name                          = "psj_crimeanalytics"
  cst_compliance_domain             = "cjis"
  cst_tenancy                       = "multiple"
  cst_application                   = "psj_crimeanalytics"
  role = each.key
  Name        = "${var.cluster_name}-${each.key}"
}


}