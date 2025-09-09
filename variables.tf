#########################################################
# Root variables.tf
#########################################################

variable "env" {
  description = "Environment name (dev/prod/etc.)"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID for FSx Lustre"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for FSx SG rules"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for FSx Lustre"
  type        = list(string)
}

variable "fsx_storage_capacity" {
  description = "FSx Lustre storage capacity in GB"
  type        = number
}

variable "use_custom_cni_policy" {
  description = "Create a custom EKS CNI policy for GovCloud"
  type        = bool
  default     = false
}

variable "eks_cni_govcloud_arn" {
  description = "GovCloud EKS CNI managed policy ARN (if available)"
  type        = string
  default     = ""
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for EBS CSI role"
  type        = string
}
