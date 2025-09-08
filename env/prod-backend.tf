terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state-prod"
    key            = "sisense/eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-prod"
    encrypt        = true
  }
}
