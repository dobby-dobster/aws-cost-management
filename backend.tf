terraform {
  required_version = ">=0.12.0"
  required_providers {
    aws = {
      version = ">=3.0.0"
    }
  }
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "aws-terraform-ansible-jenkins-env"
  }
}
