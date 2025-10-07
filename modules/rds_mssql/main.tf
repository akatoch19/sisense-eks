

# Security group for the DB
resource "aws_security_group" "db_sg" {
  name        = "${var.db_name}-rds-sg"
  description = "RDS SQL Server security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = var.eks_node_sg_ids
    description     = "Allow SQL access from EKS node groups"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.db_name}-rds-sg" })
}

# DB Subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge(var.common_tags, { Name = "${var.db_name}-subnet-group" })
}

# RDS instance
resource "aws_db_instance" "mssql" {
  identifier             = "${var.db_name}-sql"
  engine                 = "sqlserver-se"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az               = true
  storage_encrypted      = true
  skip_final_snapshot    = true

  # Windows authentication via Directory Service
  domain                = var.ad_directory_id
  domain_iam_role_name  = "AWSServiceRoleForRDS"

  tags = merge(var.common_tags, { Name = "${var.db_name}-rds" })
}
