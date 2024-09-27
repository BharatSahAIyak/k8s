# Setting up Kubecost

1. **This Helm command installs Kubecost, Prometheus, and Grafana in the _kubecost_ namespace, setting a custom authentication token with _kubecostToken_ for data retention across product tiers.**
    ```bash
    helm install kubecost cost-analyzer \
    --repo https://kubecost.github.io/cost-analyzer/ \
    --namespace kubecost --create-namespace \
    --set kubecostToken="Z2F1cmF2MjEyNWNzZUBnbWFpbC5jb20=xm343yadf98"
    ```
2. **Apply the ingress**

    ```bash
    kubectl apply -f dashboard-ingress.yaml
    ```

3. **Go to _dashboards.kubecost.io/overview_ to access the board**
