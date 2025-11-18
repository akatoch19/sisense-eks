variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  type        = string
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}
variable "aws_region" {
  type    = string
  default = ""


}