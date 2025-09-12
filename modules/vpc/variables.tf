variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "env" {
  type = string
}
variable "enable_nat_gateway" {
  description = "Create one NAT Gateway in a public subnet for all private subnets"
  type        = bool
  default     = true
}
 
variable "nat_gateway_subnet_index" {
  description = "Index of the PUBLIC subnet to host the NAT Gateway (0-based)"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
}

