provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      Environment = var.env_name
      Deployment  = var.deployment_account
      ManagedBy   = "terraform"
    }
  }
}
