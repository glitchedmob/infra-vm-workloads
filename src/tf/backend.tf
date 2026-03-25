terraform {
  backend "s3" {
    bucket         = "lz-infra-tf-state"
    key            = "lz-vm-workloads/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "lz-infra-tflock"
    encrypt        = true
  }
}
