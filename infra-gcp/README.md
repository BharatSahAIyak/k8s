# GCP Kubernetes Engine

# Steps to update infrastructure

1. `terraform plan -var-file=dev.tfvars -out plan.out`
2. `terraform apply plan.out`

Note:

1. Ensure that `dev.tfvars` is populated with the correct values for your GCP project, including project ID, region, VPC, and subnet configurations.
2. We use the existing backend [state](./state.tf) in this Terraform project, which stores the Terraform state remotely, ensuring that infrastructure changes are tracked and managed.
