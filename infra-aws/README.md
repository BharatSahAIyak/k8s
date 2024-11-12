# k8s

# Export access token and secret access key
Run this on terminal before Setup of S3 bucket and infra
```
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
```

# Steps to create S3 bucket

1. `cd infra-aws/bucket-setup`
2. Add access key and secret key to provider "aws"{} 
```
provider "aws" {
  region     = "ap-south-1"
  access_key = "YOU_ACCESS_KEY"
  secret_key = "YOU_SECRET_KEY"
  }
```
3. `terraform init`
4. `terrafrom apply`

# Steps to update infra

1. `cd ../`
2.  Add access key and secret key to provider "aws"{} 
```
provider "aws" {
  region     = "ap-south-1"
  access_key = "YOU_ACCESS_KEY"
  secret_key = "YOU_SECRET_KEY"
  }
```
3. `terraform init -reconfigure`
4. `terraform plan -var-file=dev.tfvars -out plan.out`
5. `terraform apply plan.out`

Note: 

1. Ensure the dev.tfvars is populated with right values
2. We use existing backend [state](./state.tf) in this terraform project 
