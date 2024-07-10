# k8s

# Steps to update infra

1. `terraform plan -var-file=dev.tfvars -out plan.out`
2. `terraform apply plan.out`

Note: 

1. Ensure the dev.tfvars is populated with right values
2. We use existing backend [state](./state.tf) in this terraform project 
