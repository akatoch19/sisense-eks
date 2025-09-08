resource "aws_security_group" "fsx" {
  name        = "${var.env}-fsx-sg"
  description = "Allow FSx access from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "FSx TCP 988"
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
