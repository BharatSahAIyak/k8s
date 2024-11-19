### Setting up Kong

1. Install Gateway API CRDs `kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml`
2. Create Kong Gateway Class `kubectl apply -f kong-gw-class.yaml`
3. Create a namespace for Kong `kubectl create namespace kong`
4. Create Gateway for Kong `kubectl apply -f kong-gw.yaml`
5. Install Kong CRDs `kubectl apply -k https://github.com/Kong/kubernetes-ingress-controller/config/crd`
6. Add Kong Helm Repo `helm repo add kong https://charts.konghq.com`
7. Update Helm Repos `helm repo update`
8. Install Kong Ingress `helm install kong kong/ingress --version=0.13.1 -f kong-values.yaml -n kong`
9. Enable Kong Prometheus Plugin `kubectl apply -f prometheus-plugin.yaml` (For more refer [this](https://docs.konghq.com/kubernetes-ingress-controller/latest/production/observability/prometheus-grafana/))

### Setting up Metrics Ingress:

1. Apply the ingress to expose _/metrics_ endpoint to public users: `kubectl apply -f ingress.yaml` (please update the host as needed in ingress.yaml, it is assumed that Kong has been setup)
