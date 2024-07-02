### Directory Structure

- [./terraform](./terraform): Contains all the Terraform files to set up a cluster.
  - State is stored in the same Bhasai storage backed by k8s.
  - All variables are in [terraform/dev.tfvars](./terraform/dev.tfvars).
  - [terraform/scripts](./terraform/scripts) contains the scripts for driver and admin bootstrapping.
  - [terraform/ansible/kubectl_setup.yml](./terraform/ansible/kubectl_setup.yml) configures the local kubectl on the admin server; this can also be done in Kubespray.
  
- [./manifest](./manifest): Contains all the YAMLs for the k8s cluster based on the kustomize folder structure.
  - [base](./manifest/base): Contains all the base YAMLs for the services.
  - [cluster](./manifest/cluster): Contains all the YAMLs for cluster/namespace bootstrapping.
    - [manifest/cluster/vault](./manifest/cluster/vault): [Setup instructions](https://github.com/BharatSahAIyak/docker-bhasai/discussions/312#discussioncomment-9871214). Each new namespace needs to have a [VaultAuth](./manifest/cluster/vault/static-secret.yaml).
    - [manifest/cluster/nvidia-gpu-operator](./manifest/cluster/nvidia-gpu-operator): Contains instructions to deploy the NVIDIA operator; [install_driver.sh](./manifest/cluster/nvidia-gpu-operator/install_driver.sh) needs to be run on each new host.
    - [manifest/cluster/dashboard](./manifest/cluster/dashboard): Files to install and expose the k8s-dashboard.
    - [manifest/cluster/argocd](./manifest/cluster/argocd): Contains the files to set up ArgoCD. Note for [secret.yml](./manifest/cluster/argocd/secret.yml), replace the placeholder with the actual value before applying.
  - [overlays](./manifest/overlays): Directory to use with kustomize to build final YAMLs that will be applied by ArgoCD.

Note: The admin server has all the applied YAMLs in a similar directory structure, including the Kubespray repo. Consult that in case of any discrepancy.

## Setup Instructions 

1. Go to [./terraform](./terraform), check [terraform/dev.tfvars](./terraform/dev.tfvars), and ensure all the values are correct. Apply the infrastructure.
2. Log in to the `admin` VM; all the keys are in the `~/.ssh` folder for all the other VMs.
3. Edit the `kubespray/inventory/bhasai-v1/inventory.ini` to add all the nodes; you can reference `/home/ubuntu/inventory.ini` that is generated.
4. Set up the cluster following the [Kubespray documentation](https://kubespray.io/#/?id=ansible).
5. Follow the [steps for scaling the cluster using Kubespray](https://github.com/BharatSahAIyak/docker-bhasai/discussions/303#discussioncomment-9813152).
6. Check `terraform/scripts/admin_setup.sh` for a script that does it.
7. Bootstrap the cluster as per [./manifest/cluster](./manifest/cluster) as described above in the Directory Structure.
8. Set up the load balancer and stateful machines (their setup has not been documented yet).
9. Apply [manifest/cluster/argocd/applicationset.yml](./manifest/cluster/argocd/applicationset.yml) for ArgoCD to deploy your application.