#########################################################
# FSx Lustre module (GovCloud-ready)
#########################################################

# FSx Lustre Security Group
resource "aws_security_group" "lustre_sg" {
  name        = "${var.env}-fsx-sg"
  vpc_id      = var.vpc_id
  description = "Security group for FSx Lustre"

  ingress {
    description = "Lustre LNET UDP"
    from_port   = 988
    to_port     = 988
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "Lustre LNET UDP"
    from_port   = 988
    to_port     = 988
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = var.tags
}

# FSx Lustre File System
resource "aws_fsx_lustre_file_system" "this" {
  storage_capacity           = var.fsx_storage_capacity
  subnet_ids                 = [element(var.private_subnets, 0)]
  security_group_ids         = [aws_security_group.lustre_sg.id]
  deployment_type            = "PERSISTENT_1"
  per_unit_storage_throughput = 200

  tags = var.tags
}

output "fsx_dns_name" {
  value = aws_fsx_lustre_file_system.this.dns_name
}
