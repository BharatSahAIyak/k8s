terraform {
  backend "s3" {
    bucket = "bhasaideploymentstorage"
    key    = "bhasai/live/dev-k8s"
    region = "ap-south-1"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
