# Security group for EKS worker nodes
resource "aws_security_group" "eks_nodes" {
  name        = "${var.env}-eks-nodes-sg"
  vpc_id      = var.vpc_id
  description = "Security group for EKS worker nodes"
 
  ingress {
    description = "All traffic from other nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "${var.env}-eks-nodes-sg"
  }
}
 
# Security group for FSx Lustre
# Security group for FSx Lustre
data "aws_subnets" "private" {
  ids = var.private_subnet_ids
}

locals {
  private_subnet_cidrs = [for s in data.aws_subnets.private.subnets : s.cidr_block]
}

resource "aws_security_group" "fsx" {
  name        = "${var.env}-fsx-sg"
  vpc_id      = var.vpc_id
  description = "Security group for FSx Lustre"

  # Allow Lustre port 988 from private subnets (Option 3)
  ingress {
    description = "Lustre LNET from EKS private subnets"
    from_port   = 988
    to_port     = 988
    protocol    = "tcp"
    cidr_blocks = local.private_subnet_cidrs
  }

  # Allow Lustre LNET self
  ingress {
    description = "Lustre LNET self-communication"
    from_port   = 988
    to_port     = 988
    protocol    = "tcp"
    self        = true
  }

  # All outbound allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-fsx-sg"
  }
}

/* resource "aws_security_group" "fsx" {
  name        = "${var.env}-fsx-sg"
  vpc_id      = var.vpc_id
  description = "Security group for FSx Lustre"
 
  # Allow Lustre LNET (tcp/988) from EKS worker nodes
  ingress {
    description     = "Lustre LNET from EKS nodes"
    from_port       = 988
    to_port         = 988
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }
 
  # Allow Lustre LNET (tcp/988) from itself (FSx ↔ FSx comms)
  ingress {
    description = "Lustre LNET self"
    from_port   = 988
    to_port     = 988
    protocol    = "tcp"
    self        = true
  }
 
  # All outbound allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "${var.env}-fsx-sg"
  }
} */
 
# Outputs
output "eks_nodes_sg_id" {
  description = "ID of the EKS worker nodes security group"
  value       = aws_security_group.eks_nodes.id
}
 
output "fsx_sg_id" {
  description = "ID of the FSx Lustre security group"
  value       = aws_security_group.fsx.id
}
