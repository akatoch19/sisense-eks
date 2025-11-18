resource "aws_launch_template" "ng" {
  for_each    = var.node_groups 
  #name_prefix = "eks-ng-${each.key}-"
  name = each.key 
  key_name = aws_key_pair.eks_nodes.key_name
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = each.value.disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }
 
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
       { Name = each.key }               # <- explicit
    )
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
        { Name = each.key }              # <- explicit
    )
  }
}
