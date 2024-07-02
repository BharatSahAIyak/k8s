### Directory Structure

- [./terraform](./terraform): Contains all the Terraform files to set up a cluster.
  - State is stored in the same Bhasai storage backed by k8s.
  - All variables are in [terraform/dev.tfvars](./terraform/dev.tfvars).
  - [terraform/scripts](./terraform/scripts) contains the scripts for driver and admin bootstrapping.
  - [terraform/ansible/kubectl_setup.yml](./terraform/ansible/kubectl_setup.yml) configures the local kubectl on the admin server; this can also be done in Kubespray.
  
- [./manifest](./manifest): Contains all the YAMLs for the k8s cluster based on the kustomize folder structure.
  - [base](./manifest/base): Contains all the base YAMLs for the services.
  - [cluster](./manifest/cluster): Contains all the YAMLs for cluster/namespace bootstrapping.
    - [manifest/cluster/vault](manifest/cluster/vault):  [Setup instructions](https://github.com/BharatSahAIyak/docker-bhasai/discussions/312#discussioncomment-9871214). Each new namespace needs to have a [VaultAuth](manifest/cluster/vault/static-secret.yaml).
    - [manifest/cluster/nvidia-gpu-operator](./manifest/cluster/nvidia-gpu-operator): Contains instructions to deploy the NVIDIA operator; [install_driver.sh](./manifest/cluster/nvidia-gpu-operator/install_driver.sh) needs to be run on each new host.
    - [manifest/cluster/dashboard](./manifest/cluster/dashboard): Files to install and expose the k8s-dashboard.
    - [manifest/cluster/argocd](./manifest/cluster/argocd): Contains the files to set up ArgoCD. Note for [secret.yml](./manifest/cluster/argocd/secret.yml), replace the placeholder with the actual value before applying.
  - [overlays](./manifest/overlays): Directory to use with kustomize to build final YAMLs that will be applied by ArgoCD.

Note: The admin server has all the applied YAMLs in a similar directory structure, including the Kubespray repo. Consult that in case of any discrepancy.