#########################################################
# Generate SSH key pair for all EKS node groups
#########################################################

# 1️⃣ Generate a private key
resource "tls_private_key" "eks_nodes" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2️⃣ Create an AWS key pair using the public key
resource "aws_key_pair" "eks_nodes" {
  key_name   = "sisense-eks-node-key-${var.environment}"
  public_key = tls_private_key.eks_nodes.public_key_openssh
}

# 3️⃣ (Optional but recommended) KMS key to encrypt SSM parameters
resource "aws_kms_key" "ssm_encryption" {
  description             = "KMS key to encrypt EKS SSH private key in SSM for ${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

# 4️⃣ Store private key securely in AWS SSM
resource "aws_ssm_parameter" "eks_node_private_key" {
  name        = "/sisense/${var.environment}/eks_node_private_key"
  description = "Private SSH key for Sisense EKS node access"
  type        = "SecureString"
  value       = tls_private_key.eks_nodes.private_key_pem
  key_id      = aws_kms_key.ssm_encryption.arn
  overwrite   = true
}

output "eks_ssh_key_name" {
  value       = aws_key_pair.eks_nodes.key_name
  description = "Name of SSH key used for all EKS node groups"
}

output "eks_private_key_ssm_path" {
  value       = aws_ssm_parameter.eks_node_private_key.name
  description = "SSM parameter path where private key is stored"
}
