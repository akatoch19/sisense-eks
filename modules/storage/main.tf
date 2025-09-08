# FSx for Lustre
resource "aws_fsx_lustre_file_system" "this" {
  storage_capacity   = 1200
  subnet_ids         = var.vpc_subnets
  security_group_ids = var.security_group_ids
}

# IAM role + policy for EBS CSI driver will be handled in addons
