variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster (used for IRSA trust)"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}
 
variable "oidc_provider_url" {
  type        = string
  description = "URL of the cluster's OIDC provider (without https://)"
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "enable_cluster_autoscaler" {
  type    = bool
  default = true
}
 
# Name of the IAM role that should get the policy (e.g., your nodegroup role)

variable "sa_namespace" {
  type        = string
  description = "Namespace of the service account for the cluster autoscaler"
  default     = "default"
}
 
variable "sa_name" {
  type        = string
  description = "Name of the service account for the cluster autoscaler"
  default     = "cluster-autoscaler"
}
variable "enable_ebs_csi_driver" {
  type    = bool
  default = true
}

variable "eks_oidc_url" {
  type        = string
  description = "URL of the cluster's OIDC provider (without https://)"
}