#! /bin/bash
set -ex
sudo apt-get -qq  update
sudo NEEDRESTART_MODE=a apt-get -qq install -y python3-pip
export PATH="$PATH:/home/ubuntu/.local/bin"
chmod 700 /home/ubuntu/.ssh/*.pem

if [ ! -d "kubespray" ]; then
  git clone -b release-2.25 https://github.com/kubernetes-sigs/kubespray
fi

cd kubespray/
if [ ! -d "inventory/mycluster" ]; then
  cp -rfp inventory/sample inventory/mycluster
fi

cp ../inventory.ini inventory/mycluster
pip install -r requirements.txt 
# move all the required files
#  ini file 
# kubectl_setup.yml 
# ssh keys 
ansible-playbook -i inventory/mycluster/inventory.ini  --become --become-user=root cluster.yml

cd ~

if ! command -v kubectl &> /dev/null; then
#install kubectl
curl -LO "https://dl.k8s.io/release/v1.29.5/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
fi
# setup kubectl
ansible-playbook -i kubespray/inventory/mycluster/inventory.ini  kubectl_setup.yml 


#setup the image repository
kubectl create secret docker-registry regcred --docker-server='ghcr.io' --docker-username="${DOCKER_USERNAME:?DOCKER_USERNAME is not set}" --docker-password="${DOCKER_PASSWORD:?DOCKER_PASSWORD is not set}"
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'

