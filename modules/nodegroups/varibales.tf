variable "cluster_name" {
  description = "EKS cluster name to attach the node groups"
  type        = string
}

variable "desired_size" {
  description = "Desired number of worker nodes in node groups"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes in node groups"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes in node groups"
  type        = number
}

variable "instance_types" {
  description = "List of EC2 instance types for worker nodes"
  type        = list(string)
}

variable "disk_size" {
  description = "EBS volume size (in GiB) for each worker node"
  type        = number
}

variable "node_iam_role" {
  description = "IAM role ARN to associate with EKS node groups"
  type        = string
}

variable "extra_userdata" {
  description = "Path to the user data bootstrap script template"
  type        = string
}

variable "namespace" {
  description = "Namespace for Sisense (used in node labels)"
  type        = string
}
