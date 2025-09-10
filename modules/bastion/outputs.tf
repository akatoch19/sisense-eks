output "bastion_id" {
  value       = aws_instance.bastion.id
  description = "EC2 ID of bastion host"
}

output "bastion_private_ip" {
  value       = aws_instance.bastion.private_ip
  description = "Private IP of the bastion host"
}
