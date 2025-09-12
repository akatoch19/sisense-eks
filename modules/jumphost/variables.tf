# Required variables
variable "region" {
  type        = string
  description = "AWS region to deploy resources in"
}

variable "env" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the resources will be deployed"
}


variable "key_name" {
  type        = string
  description = "Key pair name for SSH access to EC2"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (e.g., t2.micro)"
}

# Optional variables (used for dynamic subnet detection via tags)
variable "private_subnet_tag_key" {
  type        = string
  default     = "kubernetes.io/role/internal-elb"
  description = "Tag key to identify private subnets"
}

variable "private_subnet_tag_value" {
  type        = string
  default     = "1"
  description = "Tag value to identify private subnets"
}
variable "cluster_name" {
  type        = string
  description = "Name of the existing EKS cluster"
}
variable "subnet_id" {
  description = "The subnet ID where the jumphost will be deployed"
  type        = string
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "cluster_sg_id" {
  description = "The ID of the EKS cluster security group"
  type        = string
}
variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name to attach to jumphost EC2"
  type        = string
   default     = null
}
