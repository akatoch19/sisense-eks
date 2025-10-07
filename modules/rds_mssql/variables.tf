variable "vpc_id" {
    type = string
}
variable "env" {
  type = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}
variable "db_name" { 
    default = "sisense"
}
variable "instance_class" {
     default = "db.m6i.xlarge"
}
variable "engine_version" {
    default = "16.00"
} 
variable "allocated_storage" { 
    default = "200" 
 }
variable "username" { 
    default = "cstsqladmin"
 }
#variable "ad_directory_id" {
#  description = "Directory Service ID for Windows Authentication"
#}
variable "eks_node_sg_ids" {
  description = "List of SG IDs for node groups that need DB access"
  type        = list(string)
}
variable "common_tags" { 
    type = map(string) 
}