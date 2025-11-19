variable "vpc_id" {}
variable "fsx_sg_ingress_port" {
 default = 988
 }
variable "env" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}
