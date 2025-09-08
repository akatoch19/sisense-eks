variable "ebs_service_account" {
  description = "Name of the service account for the EBS CSI driver"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster (used for autoscaler autodiscovery)"
  type        = string
}
