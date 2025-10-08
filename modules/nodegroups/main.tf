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

resource "aws_launch_template" "nodegroup" {
  for_each      = local.node_groups
  name_prefix   = "${var.cluster_name}-${each.key}-"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = each.value.instance_types[0]  # single instance type
  key_name      = var.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = each.value.disk_size
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.cluster_name}-${each.key}"
        role = each.key
      }
    )
  }
}

module "nodegroups" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.0.0"

  for_each      = local.node_groups
  cluster_name  = var.cluster_name
  subnet_ids    = var.subnet_ids
  name          = each.key
  desired_size  = each.value.desired_size
  min_size      = each.value.min_size
  max_size      = each.value.max_size
  labels        = each.value.labels
  capacity_type = each.value.capacity_type

  launch_template {
    id      = aws_launch_template.nodegroup[each.key].id
    version = "$Latest"
  }

  # Node group tags (applied to the EKS Node Group itself)
  tags = merge(
    var.tags,
    {
      role = each.key
    }
  )
}
