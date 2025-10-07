 #Security group for the DB
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
# Generate a secure password for RDS
resource "random_password" "db_master" {
 length              = 32      # <= 128
  special             = true
  override_special = "!,.-=_%@"
}
# Store it in SSM Parameter Store (SecureString)
resource "aws_ssm_parameter" "db_master_password" {
  name   = "/${var.env}/${var.db_name}/rds/master_password"
  type   = "SecureString"
  value  = random_password.db_master.result
  #key_id = try(var.parameter_kms_key_id, null)  # optional KMS key
  tags   = var.common_tags
}
# RDS instance
resource "aws_db_instance" "mssql" {
  identifier             = "${var.db_name}-sql"
  engine                 = "sqlserver-se"
  license_model          = "license-included"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.username
  backup_retention_period = 1
  password               = random_password.db_master.result
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az               = true
  storage_encrypted      = true
  skip_final_snapshot    = true
  # Windows authentication via Directory Service
  #domain                = var.ad_directory_id
  #domain_iam_role_name  = "AWSServiceRoleForRDS"
  tags = merge(var.common_tags, { Name = "${var.db_name}-rds" })
}