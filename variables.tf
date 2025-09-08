variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "sisense-eks"
}

variable "environment" {
  description = "Environment (production/staging)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "sisense_license_key" {
  description = "Sisense license key"
  type        = string
  sensitive   = true
}

variable "sisense_domain" {
  description = "Sisense domain name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Sisense"
  type        = string
  default     = "sisense"
}
