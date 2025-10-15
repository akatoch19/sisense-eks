# Generate SSH key if none provided
resource "tls_private_key" "eks_ssh" {
   count    = var.ssh_key_name == null ? 1 : 0
   algorithm = "RSA"
   rsa_bits  = 4096
 }

 # Create AWS Key Pair from the generated public key
 resource "aws_key_pair" "eks_key" {
   count      = var.ssh_key_name == null ? 1 : 0
   key_name   = "${var.cluster_name}-eks-key"
   public_key = tls_private_key.eks_ssh[0].public_key_openssh
 }

 # Store private key securely in SSM Parameter Store
 resource "aws_ssm_parameter" "eks_private_key" {
   count      = var.ssh_key_name == null ? 1 : 0
   name       = var.ssm_ssh_key_param_name
   type       = "SecureString"
  value      = tls_private_key.eks_ssh[0].private_key_pem
   description = "Private SSH key for EKS nodes"
   overwrite   = true
 }

 resource "aws_launch_template" "ng" {
   for_each    = local.node_groups
   name_prefix = "eks-ng-${each.key}-"

  # Attach SSH key name (either provided or newly created)
  key_name = var.ssh_key_name != null ? var.ssh_key_name : aws_key_pair.eks_key[0].key_name
 
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
       { Name = each.value.name_tag }
     )
   }
 }
