variable "cluster_name" {}
variable "vpc_id" {}
variable "private_subnets" {}
variable "node_security_group_id" {}
variable "environment" {}
variable "fsx_security_group_id" {}

# FSx for Lustre
resource "aws_fsx_lustre_file_system" "sisense" {
  storage_capacity            = 1024
  deployment_type             = "PERSISTENT_1"
  per_unit_storage_throughput = 200
  subnet_ids                  = [var.private_subnets[0]]
  security_group_ids          = [var.fsx_security_group_id]

  tags = {
    Name        = "${var.cluster_name}-fsx"
    Environment = var.environment
  }
}

# Storage Classes
resource "kubernetes_storage_class" "sisense_ssd" {
  metadata {
    name = "sisense-ssd"
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    iops      = "1600"
    throughput = "100"
    encrypted = "true"
  }

  allow_volume_expansion = true
}

output "fsx_filesystem_id" {
  value = aws_fsx_lustre_file_system.sisense.id
}
