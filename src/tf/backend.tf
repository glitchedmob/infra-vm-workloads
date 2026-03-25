terraform {
  backend "s3" {
    bucket         = "levizitting-infra-tf-state"
    key            = "vm-workloads/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
