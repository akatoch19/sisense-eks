variable "vpc_id" {}
variable "fsx_sg_ingress_port" {
 default = 988
 }
variable "env" {
  type = string
}

variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
}
