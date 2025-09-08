terraform {
  backend "s3" {
    bucket = "sisense-terraform-state-${var.aws_region}-prod"
    key    = "sisense/eks/terraform.tfstate"
    region = var.aws_region
    dynamodb_table = "sisense-terraform-locks-prod"
    encrypt        = true
    }
}
