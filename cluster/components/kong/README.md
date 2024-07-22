### Setting up Kong

1. Install Gateway API CRDs `kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml`
2. Create Kong Gateway Class `kubectl apply -f kong-gw-class.yaml`
3. Create a namespace for Kong `kubectl create namespace kong`
4. Create Gateway for Kong `kubectl apply -f kong-gw.yaml`
5. Install Kong CRDs `kubectl apply -k https://github.com/Kong/kubernetes-ingress-controller/config/crd`
6. Add Kong Helm Repo `helm repo add kong https://charts.konghq.com`
7. Update Helm Repos `helm repo update`
8. Install Kong Ingress `helm install kong kong/ingress -f kong-values.yaml -n kong`
