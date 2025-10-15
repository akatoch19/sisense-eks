###############################################
# SSH keypair creation and secure storage
###############################################

resource "tls_private_key" "eks_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "eks_keypair" {
  key_name   = "${var.env}-eks-node-key"
  public_key = tls_private_key.eks_ssh_key.public_key_openssh
}

# Store private key securely in SSM Parameter Store
resource "aws_ssm_parameter" "eks_private_key" {
  name        = "/${var.env}/eks/private_key"
  description = "Private key for SSH access to EKS node groups"
  type        = "SecureString"
  value       = tls_private_key.eks_ssh_key.private_key_pem
  tags        = merge(local.common_tags, { "Name" = "${var.env}-eks-private-key" })
}

output "eks_key_name" {
  description = "SSH key name for EKS node groups"
  value       = aws_key_pair.eks_keypair.key_name
}
