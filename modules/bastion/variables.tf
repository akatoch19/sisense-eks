variable "env" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "ami_id" { type = string }
variable "instance_type" { type = string, default = "t3.medium" }
variable "key_name" { type = string, default = "" }  # optional with SSM
