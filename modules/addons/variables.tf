variable "ebs_service_account" {
  description = "Name of the service account for the EBS CSI driver"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster (used for autoscaler autodiscovery)"
  type        = string
}

variable "ebs_role_arn" {
  description = "IAM role ARN for the EBS CSI driver service account"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN"
  type        = string
}
 
variable "eks_oidc_provider_url" {
  description = "EKS OIDC Provider URL"
  type        = string
}

variable "env" {
  description = "EKS OIDC Provider URL"
  type        = string
}
variable "eks_oidc_issuer" {
  type = string
}