# k8s

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

1. `cd infra-aws`
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
