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