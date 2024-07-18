# Scaling Kubernetes

## Up-Scaling 

### Provisioning a node on Azure

1. Increase the node count (e.g., increase k8s_worker_node_count by 1 to provision a non-gpu worker node ) in [dev.tfvars](../infra/dev.tfvars)
2. Run `terraform plan -var-file=dev.tfvars -out plan.out` to generate the plan (ensure to properly review the output of this command)
3. Run `terraform plan plan.out` to apply the changes to infrastructure

Note: This automatically updated the inventory.ini file on the admin machine with newly provisioned node. 

### Adding the node to the Cluster

1. SSH into admin machine (use admin.pem generated while setting up Infra)
2. Run `cp inventory.ini kubespray/inventory/kubespray-vars/inventory.ini` (in case you have manually updated inventory.ini inside kubespray-vars for any requirements, you can add entry for the newly added node to the inventory.ini file inside kubespray-vars manually)
3. Change the directory to kubespray `cd kubespray`
4. Run `ansible-playbook -i inventory/kubespray-vars/inventory.ini scale.yml -b -v`
5. Run `kubectl get node` to verify if node is successfully attached to cluster and ready for use

## Down-Scaling 

### Removing the node from the cluster

1. SSH into admin machine (use admin.pem generated while setting up Infra)
2. Change the directory to kubespray `cd kubespray`
3. Run `ansible-playbook -i inventory/kubespray-vars/inventory.ini remove-node.yml -b -v --extra-vars "node=<node-name>" ` (replace <node-name> with the name of node you want to remove)
4. Run `kubectl get node` to verify if node is successfully removed from the cluster

### Remove the node from Azure

1. Decrease the node count (e.g., decrease k8s_worker_node_count by 1 to remove one non-gpu worker node ) in [dev.tfvars](../infra/dev.tfvars)
2. Run `terraform plan -var-file=dev.tfvars -out plan.out` to generate the plan (ensure to properly review the output of this command)
3. Run `terraform plan plan.out` to apply the changes to infrastructure
4. SSH into admin machine (use admin.pem generated while setting up Infra)
4. Run `cp inventory.ini kubespray/inventory/kubespray-vars/inventory.ini` to keep the inventory.ini file inside kubespray upd to date (in case you have manually updated inventory.ini inside kubespray-vars for any requirements, you can remove entry for the recently removed node to the inventory.ini file inside kubespray-vars manually)
