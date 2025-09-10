variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "enable_oidc_provider" {
  description = "Enable OIDC provider for IRSA"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Existing KMS key ARN to encrypt Kubernetes secrets. Leave null to disable encryption."
  type        = string
  default     = null
}


variable "env" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}
