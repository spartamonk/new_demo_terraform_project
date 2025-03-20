terraform {
  backend "s3" {
    bucket         = "new-terraform-state-file-cma"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "test-table"
    encrypt        = true
  }
}