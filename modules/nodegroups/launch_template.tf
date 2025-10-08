resource "aws_launch_template" "ng" {
  for_each    = local.node_groups
  name_prefix = "eks-ng-${each.key}-"
 
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = each.value.disk_size_gib
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }
 
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      { Name = each.value.name_tag }               # <- explicit
    )
  }
 
}