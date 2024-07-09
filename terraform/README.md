# k8s

remote state -> use existing from docker-bhasai

# Steps to update infra

1. `terraform plan -var-file=dev.tfvars -out plan.out`
2. `terraform apply plan.out`

Note: Ensure the dev.tfvars is populated with right values
