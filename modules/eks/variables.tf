variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for worker nodes"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "enable_oidc_provider" {
    description = "Enable OIDC provider for IA"
}
 
 variable "env" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "jumphost_role_arn" {
  type = string
}

variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
}
