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
 

variable "tags" {
  type    = map(string)
  default = {}
}
 variable "fsx_csi_irsa_role_arn" {
  type        = string
  description = "ARN of the IAM role for FSx CSI IRSA"
}

 variable "cluster_autoscaler_irsa_role_arn" {
  type        = string
  description = "IAM role ARN for cluster autoscaler IRSA"
}
variable "region" {
  type    = string


}
variable "ebs_csi_irsa_role_arn" {
  type        = string
  description = "IRSA role ARN for EBS CSI controller"
}
variable "fsx_irsa_role_arn" {
  type        = string
  description = "ARN of the IAM role for FSx CSI IRSA"
  default     = null
}
 

variable "ebs_csi_role_arn" {
  type = string
}
variable "enable_ebs_csi" {
  description = "Whether to enable the EBS CSI driver addon"
  type        = bool
  default     = true   # or false if you want it disabled by default
}


 
 