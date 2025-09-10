output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP of the bastion host"
}

output "bastion_id" {
  value       = aws_instance.bastion.id
  description = "EC2 ID of the bastion host"
}
