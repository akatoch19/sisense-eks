# Discover AZs (we'll fan subnets across them by index)
data "aws_availability_zones" "available" {}
 
# -----------------------
# VPC
# -----------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
 
  tags = {
    Name = "${var.env}-vpc"
    Env  = var.env
  }
}
 
# -----------------------
# Subnets
# -----------------------
resource "aws_subnet" "private" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
 
  tags = {
    Name = "${var.env}-private-${count.index + 1}"
    Env  = var.env
    # (Optional EKS LB tags)
    # "kubernetes.io/role/internal-elb"           = "1"
    # "kubernetes.io/cluster/${var.env}-cluster"  = "shared"
  }
}
 
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
 
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
    Env  = var.env
    # (Optional EKS LB tags)
    # "kubernetes.io/role/elb"                    = "1"
    # "kubernetes.io/cluster/${var.env}-cluster"  = "shared"
  }
}
 
# -----------------------
# Internet Gateway (for public egress and NAT upstream)
# -----------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.env}-igw"
  }
}
 
# -----------------------
# Public routing (0/0 -> IGW)
# -----------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.env}-public-rt"
  }
}
 
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
 
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
 
# -----------------------
# Optional NAT (single) for all private subnets
# -----------------------
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = {
    Name = "${var.env}-nat-eip"
  }
}
 
resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[var.nat_gateway_subnet_index].id
  tags = {
    Name = "${var.env}-nat-gw"
  }
  depends_on = [aws_internet_gateway.this]
}
 
# Private route table (default route to NAT)
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.env}-private-rt"
  }
}
 
resource "aws_route" "private_default" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}
 
resource "aws_route_table_association" "private_assoc" {
  for_each = var.enable_nat_gateway ? {
    for idx, s in aws_subnet.private : idx => s.id
  } : {}
  subnet_id      = each.value
  route_table_id = aws_route_table.private[0].id
}
 
# -----------------------
# Outputs
# -----------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}
 
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}
 
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}
 
output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}
 
output "private_route_table_id" {
  description = "Private route table ID (present only if NAT enabled)"
  value       = try(aws_route_table.private[0].id, null)
}
 
output "nat_gateway_id" {
  description = "NAT Gateway ID (present only if NAT enabled)"
  value       = try(aws_nat_gateway.this[0].id, null)
}