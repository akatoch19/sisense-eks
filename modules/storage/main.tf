# FSx Lustre
resource "aws_fsx_lustre_file_system" "this" {
  storage_capacity    = var.fsx_storage_capacity
  subnet_ids           = [element(var.private_subnets, 0)]
  security_group_ids  = [var.fsx_sg_id]
  deployment_type     = "PERSISTENT_1"
  per_unit_storage_throughput = 200

  tags = var.tags
}

output "fsx_dns_name" { value = aws_fsx_lustre_file_system.this.dns_name }
