# bucket-setup/bucket-setup.tf
provider "aws" {
  region     = "ap-south-1"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "bhasaideploymentstorage"  # Ensure this is a unique name across S3


  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Dev"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_state_bucket.bucket
}
