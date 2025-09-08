variable "cluster_name" {}
variable "environment" {}
variable "vpc_id" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "azs" {}

data "aws_ami" "eks_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.31-*"]
  }
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = var.private_subnets
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [aws_security_group.cluster.id]
  }

  tags = {
    Environment = var.environment
    Application = "Sisense"
  }
}

resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Node Groups
resource "aws_eks_node_group" "application" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-application"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = var.environment == "production" ? 2 : 1
    max_size     = var.environment == "production" ? 4 : 2
    min_size     = var.environment == "production" ? 2 : 1
  }

  instance_types = var.environment == "production" ? ["r5.8xlarge"] : ["r5.2xlarge"]

  labels = {
    "node-sisense-Application" = "true"
    "node-sisense-Query"       = "true"
  }

  tags = {
    Environment = var.environment
    Application = "Sisense-Application"
  }
}

resource "aws_eks_node_group" "build" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-build"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = 1
    max_size     = var.environment == "production" ? 2 : 1
    min_size     = 1
  }

  instance_types = var.environment == "production" ? ["r5.8xlarge"] : ["r5.2xlarge"]

  labels = {
    "node-sisense-Build" = "true"
  }

  tags = {
    Environment = var.environment
    Application = "Sisense-Build"
  }
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "oidc_provider_arn" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_url" {
  value = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}

output "node_iam_instance_profile" {
  value = aws_iam_instance_profile.nodes.name
}
