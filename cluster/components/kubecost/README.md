# Setting up Kubecost

1. This Helm command installs Kubecost, Prometheus, and Grafana in the _kubecost_ namespace

    ```bash
    helm upgrade --install kubecost \
    --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
    --namespace kubecost --create-namespace
    ```

2. Configuring Ingress:

    1. Ensure that Kong is set up as your ingress controller.
    2. Modify the _dashboard-ingress.yaml_ file:
        - Replace the placeholder _YourKubecostHostname_ with your specific hostname for the Kubecost dashboard.

    3. Apply the Ingress configuration:

        ```bash
        kubectl apply -f dashboard-ingress.yaml
        ```

3. Accessing the Kubecost Dashboard

    Navigate to your specified hostname in a browser: _YourKubecostHostname_


Refer the [official documentation](https://docs.kubecost.com/install-and-configure/install) for more info.