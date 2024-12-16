terraform {
  backend "s3" {
    bucket = "ksproddeploymentstorage"
    key    = "ks/live/prod-k8s"
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
