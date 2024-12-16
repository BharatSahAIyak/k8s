provider "aws" {
  region     = "ap-south-1"
  # access_key = "YOU_ACCESS_KEY"
  # secret_key = "YOU_SECRET_KEY"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "ksproddeploymentstorage"


  tags = {
    Name        = "Terraform State Bucket for Production"
    Environment = "Production"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_state_bucket.bucket
}
