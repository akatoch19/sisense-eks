variable "fsx_storage_capacity" {
  description = "The storage capacity (in GiB) for FSx Lustre"
  type        = number
  default     = 1200
}

variable "private_subnets" {
  description = "List of private subnet IDs where FSx will be deployed"
  type        = list(string)
}

variable "fsx_sg_id" {
  description = "Security Group ID for FSx"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}