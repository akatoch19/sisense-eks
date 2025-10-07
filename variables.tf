# Environment
variable "env" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"

}
variable "ami_type" {
  description = "The AMI type for the node group"
  type        = string
  default     = "AL2_x86_64"
}

variable "vpc_id" {
  description = "ID of the existing VPC to deploy into"
  type        = string
  default     =  "vpc-069b89b9b7e34fda1"
}

variable "private_subnets" {
  type    = list(string)
  default = ["subnet-06e67684de6f297e6", "subnet-04a89427e7493986d", "subnet-07b9b67491137739d"]
}
# EKS
variable "cluster_name" {
  type    = string
  default = "sisense-staging-eks"
}

variable "k8s_version" {
  type    = string
  default = "1.33"
}

variable "enable_oidc_provider" {
  type    = bool
  default = true
}

# Node Groups
#variable "instance_types" {
 # type    = list(string)
 # default = ["c6g.large"]
#}

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
variable "tags" {
  type    = map(string)
  default = {}
}

variable "jumphost_subnet_index" {
  type    = number
  default = 0
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the jumphost"
  default     = "t3.micro"
}


variable "db_password" {
  description = "RDS admin password"
  type        = string
  sensitive   = true
}

variable "ad_directory_id" {
  description = "Directory Service ID for Windows Authentication"
  type        = string
}
