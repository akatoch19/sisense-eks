resource "aws_fsx_lustre_file_system" "this" {
  storage_capacity    = var.capacity
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.fsx.id]
  deployment_type     = "SCRATCH_2"
}

resource "aws_security_group" "fsx" {
  name        = "${var.env}-fsx-sg"
  vpc_id      = var.vpc_id
  description = "FSx SG"

  ingress {
    from_port   = 988
    to_port     = 988
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
