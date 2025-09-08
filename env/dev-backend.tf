terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state-dev"
    key            = "sisense/eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-dev"
    encrypt        = true
  }
}
