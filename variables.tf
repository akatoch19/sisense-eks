variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile name"
}

variable "env_name" {
  type        = string
  description = "Environment name (dev/prod)"
}

variable "deployment_account" {
  type        = string
  description = "Deployment account owner tag"
}

variable "eks_version" {
  type        = string
  default     = "1.31"
}

variable "fsx_storage_capacity" {
  type        = number
  default     = 1200 # in GB
}
