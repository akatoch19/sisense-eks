variable "env" {
  type        = string
  description = "Environment (dev, staging, prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where bastion will be deployed"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the bastion instance"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the bastion EC2"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "key_name" {
  type        = string
  description = "SSH key name for EC2 access"
}

variable "my_ip" {
  type        = string
  description = "Your public IP for SSH access"
}
