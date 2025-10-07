output "rds_endpoint" {
  value = aws_db_instance.mssql.address
}

output "rds_sg_id" {
  value = aws_security_group.db_sg.id
}
