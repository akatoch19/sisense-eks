# Environment
variable "env" {
  type = string
}

variable "aws_region" {
  type    = string
  default = ""

}
variable "aws_partition" {
  type    = string
  default = ""

}
variable "ami_type" {
  description = "The AMI type for the node group"
  type        = string
}
variable "use_networking_remote_state" {
  type    = bool
  default = false
}

variable "private_subnets" {
  type    = list(string)
  default = []
}
# EKS
variable "cluster_name" {
  type    = string
}

variable "k8s_version" {
  type    = string
}

variable "enable_oidc_provider" {
  type    = bool
  default = true
}
variable "fsx_version" {
  type    = string
}


variable "node_groups" {
  description = "Min/max/desired/instance types per node group"
  type = map(object({
    desired_size   = number
    min_size       = number
    max_size       = number
    instance_types = list(string)
    disk_size = number
  }))
  default     = {}
}

variable "namespace" {
  type    = string
  default = "sisense"
}

# FSx
variable "fsx_storage_capacity" {
  type    = number
}

# DNS
variable "zone_name" {
 type    = string
default = ""
}

variable "fsx_sg_ingress_port" {
  description = "Port for FSx Lustre inbound traffic (default 988)"
  type        = number
  default     = 988
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "jumphost_subnet_index" {
  type    = number
  default = 0
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the jumphost"
 
}

variable "sa_namespace" {
  type        = string
  description = "Namespace of the service account for the cluster autoscaler"
  default     = "default"
}
 
variable "sa_name" {
  type        = string
  description = "Name of the service account for the cluster autoscaler"
  default = ""

}
variable "account_vpc_name" {
  type        = string
  description = "Name tag of the VPC for this EKS cluster"
}
variable "aws_account_id" {
  type = string
}
 variable "cluster_service_cidr" {
  type        = string
  description = "Kubernetes service CIDR block"
  default     = "172.20.0.0/16"
}
variable "enable_ebs_csi_driver" {
  type    = bool
  default = true
}
variable "cloud_admin_entrypoint_role_arn" {
  description = "IAM role ARN that acts as the cloud admin entry point for EKS"
  type        = string
}

variable "target_deployment_role" {
  type        = string
  description = "name of the role to assume from deployment account"
}

#variable "ad_directory_id" {
 # description = "Directory Service ID for Windows Authentication"
 # type        = string
#}
/*variable "db_subnets" { 
  type = list(string)
   }
variable "db_name" { 
  type = string 
  }
variable "db_username" {
   type = string
    }
variable "db_instance_class" { 
  type = string 
  }
  variable "common_tags" {
  type        = map(string)
  default     = {}
}
variable "region" {
  type    = string

}*/