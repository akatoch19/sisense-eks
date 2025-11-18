variable "cluster_name" {
  description = "EKS cluster name to attach the node groups"
  type        = string
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
#variable "instance_types" {
  #description = "List of EC2 instance types for worker nodes"
 # type        = list(string)
 # default = {}
#}

variable "node_role_arn" {
  description = "IAM role ARN to associate with EKS node groups"
  type        = string
}

variable "namespace" {
  description = "Namespace for Sisense (used in node labels)"
  type        = string
}

variable "subnet_ids" {
  type = list(string)
}
variable "ami_type" {
  description = "The AMI type for the node group"
  type        = string
}


variable "node_iam_role" {
  description = "IAM role ARN to associate with EKS node groups"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "env" {
  type = string
}
variable "create_cni_policy" {
  description = "Whether to create the CNI policy for the node group"
  type        = bool
  default     = false
}
variable "cluster_service_cidr" {
  type        = string
  description = "Kubernetes service CIDR"
}

