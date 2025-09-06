terraform {
  backend "s3" {
    bucket         = "my-sisense-terraform-state-dev"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sisense-terraform-locks-dev"
    encrypt        = true
  }
}
