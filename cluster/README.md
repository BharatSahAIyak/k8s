### Pre-requisites:

1. SSH into admin machine (use admin.pem generated while setting up Infra)
2. Run `sudo apt-get install build-essential` to install essential packages
3. Clone this repository at ~ `git clone https://github.com/BharatSahAIyak/k8s.git`
4. RUN `cd k8s/setup`
5. Run `make base-setup`        

### Steps to setup cluter

1. Clone kubespray repository at ~ `git clone -b release-2.25 https://github.com/kubernetes-sigs/kubespray`
3. `cp -r k8s/setup/kubespray-vars kubespray/inventory/kubespray-vars`
4. `cp inventory.ini kubespray/inventory/kubespray-vars/inventory.ini` 
5. Change the directory to kubespray `cd kubespray`
6. Install essesntial python packages `pip install -r requirements.txt`
7. RUN `ansible-playbook -i inventory/kubespray-vars/inventory.ini  --become --become-user=root cluster.yml` to bootstrap the cluster

### Steps to configure kubeconfig on Admin

1. Run `ansible-playbook -i kubespray/inventory/kubespray-vars/inventory.ini k8s/cluster/scripts/setup-kubeconfig.yaml`


