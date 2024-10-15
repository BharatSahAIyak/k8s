# Setting up Kubecost
This guide provides step-by-step instructions to set up the Kubecost Dashboard.

**Setting up Dashboard:**

1. Add the Kubecost Dashboard Helm repository: `helm repo add kubecost https://kubecost.github.io/cost-analyzer/
`

2. This Helm command installs Kubecost, Prometheus, and Grafana in the _kubecost_ namespace: `helm upgrade --install kubecost kubecost/cost-analyzer --namespace kubecost --create-namespace -f values.yaml
`

**Setting up Dashboard Ingress:**

1. Apply the ingress to expose Kubecost dashboard to public users `kubectl apply -f ingress.yaml` (please update the host as needed in ingress.yaml, it is assumed that Kong has been setup)


**References**

- For more information, visit these:
[Ref 1](https://docs.kubecost.com/install-and-configure/install) & [Ref 2](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-grafana)