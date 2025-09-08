

# SG for EKS nodes
resource "aws_security_group" "eks_nodes" {
  name   = "${var.env}-eks-nodes-sg"
  vpc_id = var.vpc_id
  description = "Security group for EKS worker nodes"

  ingress {
    description      = "All traffic from other nodes"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self             = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env}-eks-nodes-sg" }
}

# SG for FSx Lustre
resource "aws_security_group" "fsx" {
  name   = "${var.env}-fsx-sg"
  vpc_id = var.vpc_id
  description = "Security group for FSx Lustre"

  ingress {
    description = "Allow inbound from EKS nodes"
    from_port   = var.fsx_sg_ingress_port
    to_port     = var.fsx_sg_ingress_port
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env}-fsx-sg" }
}
