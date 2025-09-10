# Environment
variable "env" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-gov-west-1"
}

# VPC
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]
}
# NAT controls (separate, as requested)
variable "enable_nat_gateway" {
  description = "Create one NAT Gateway in a public subnet for all private subnets"
  type        = bool
  default     = true
}
 
variable "nat_gateway_subnet_index" {
  description = "Index of the PUBLIC subnet to host the NAT GW (0-based)"
  type        = number
  default     = 0
}
# EKS
variable "cluster_name" {
  type    = string
  default = "sisense-eks"
}

variable "k8s_version" {
  type    = string
  default = "1.32"
}

variable "enable_oidc_provider" {
  type    = bool
  default = true
}

# Node Groups
variable "instance_types" {
  type    = list(string)
  default = ["m5.4xlarge"]
}

variable "disk_size" {
  type    = number
  default = 400
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 1
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "extra_userdata" {
  type    = string
  default = "userdata/bootstrap.sh"
}

variable "namespace" {
  type    = string
  default = "sisense"
}

# FSx
variable "fsx_storage_capacity" {
  type    = number
  default = 1200
}

# DNS
#variable "zone_name" {
 # type    = string
  #default = "sisense.myleslie.com"
#}

variable "fsx_sg_ingress_port" {
  description = "Port for FSx Lustre inbound traffic (default 988)"
  type        = number
  default     = 988
}

variable "bastion_ami_id" {
  description = "AMI ID for the bastion EC2"
}

variable "public_subnet_id" {
  description = "Public subnet ID for bastion host"
}

variable "key_name" {
  description = "SSH key name for bastion EC2"
}

variable "my_ip" {
  description = "Your public IP address in CIDR format, e.g., 203.0.113.25/32"
}




