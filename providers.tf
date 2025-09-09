provider "aws" {
  region = var.aws_region
  profile = "terraform"
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

