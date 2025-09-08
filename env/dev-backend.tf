terraform {
  backend "s3" {
    bucket = "sisense-terraform-state-${var.aws_region}-dev"
    key    = "sisense/eks/terraform.tfstate"
    region = var.aws_region
    dynamodb_table = "sisense-terraform-locks-dev"
    encrypt        = true
    }
}
