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
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
fi
# setup kubectl
ansible-playbook -i kubespray/inventory/mycluster/inventory.ini  kubectl_setup.yml 

#setup kong ingress
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
echo "
---
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
 name: kong
 annotations:
   konghq.com/gatewayclass-unmanaged: 'true'

spec:
 controllerName: konghq.com/kic-gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
 name: kong
spec:
 gatewayClassName: kong
 listeners:
 - name: proxy
   port: 80
   protocol: HTTP
" | kubectl apply -f -

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add kong https://charts.konghq.com
helm repo update

cat > kong-values.yml <<EOF
#controller:
#  ingressController:
#    env:
#      LOG_LEVEL: trace
#      dump_config: true

gateway:
  admin:
    http:
      enabled: true
  proxy:
    type: NodePort
    http:
      enabled: true
      nodePort: 32001
    tls:
      enabled: false
#  ingressController:
#    env:
#      LOG_LEVEL: trace
EOF
helm install kong kong/ingress -n kong --create-namespace -f kong-values.yml