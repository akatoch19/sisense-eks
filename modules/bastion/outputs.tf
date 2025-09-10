output "jumphost_id" {
  value       = aws_instance.jumphost.id
  description = "EC2 ID of the jumphost"
}
 
output "jumphost_private_ip" {
  value       = aws_instance.jumphost.private_ip
  description = "Private IP of the jumphost"
}