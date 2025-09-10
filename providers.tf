provider "aws" {
  region = var.aws_region
  profile = "default"
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
