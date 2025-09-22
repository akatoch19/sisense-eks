

#resource "aws_launch_template" "eks_common" {
  #name_prefix = "sisense-eks-common-"
 
 # metadata_options {
 #   http_tokens = "required"
 # }
 
  # 1) Instance tags
 # tag_specifications {
 #   resource_type = "instance"

  #}
 
  # 2) Volume tags (same keys/values)
 
  #}
#}

#output "launch_template" {
  #value = {
    #id      = aws_launch_template.eks_common.id
    #version = aws_launch_template.eks_common.latest_version
  #}
#}

