# Security group for EKS worker nodes (as you had)
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
 
  tags = var.tags
}
#####################################
# Security group for FSx Lustre
#####################################
resource "aws_security_group" "fsx" {
  name        = "${var.env}-fsx-sg"
  vpc_id      = var.vpc_id
  description = "Security group for FSx Lustre"
 
  # Allow 988 from EKS node SG
  ingress {
    description     = "Lustre LNET from EKS nodes"
    from_port       = 988
    to_port         = 988
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]   
  }
 
  ingress {
    description     = "Lustre control ports from EKS nodes"
    from_port       = 1018
    to_port         = 1023
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]   
  }
 #############################
  # FSx self
#############################
  ingress {
    description = "Lustre self"
    from_port   = 988
    to_port     = 988
    protocol    = "tcp"
    self        = true
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = var.tags
}
 
output "eks_nodes_sg_id" {
  description = "ID of the EKS worker nodes security group"
  value       = aws_security_group.eks_nodes.id
}
 
output "fsx_sg_id" {
  description = "ID of the FSx Lustre security group"
  value       = aws_security_group.fsx.id
}
