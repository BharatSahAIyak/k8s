# Kubernetes Dashboard Setup

This guide provides step-by-step instructions to set up the Kubernetes Dashboard, including obtaining Bearer Tokens for authentication.

**Setting up Dashboard:**

1. Install the Kubernetes Dashboard Using Helm
* Add the Kubernetes Dashboard Helm repository: `helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/`
* Install or upgrade the Kubernetes Dashboard release: `helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -f values.yaml --create-namespace --namespace kubernetes-dashboard`


**Authentication Token Creation**

1. Create a Service Account: `kubectl apply -f dashboard-adminuser.yaml`
2. Create a Cluster Role Binding: `kubectl apply -f dashboard-clusterrolebinding.yaml`
3. You can create either a temporary or long-lived token:
    1. Create a Temporary Bearer Token: `kubectl -n kubernetes-dashboard create token admin-user`  
    or
    2. Create a Long-Lived Bearer Token:   
    * `kubectl apply -f dashboard-adminuser-secret.yaml`   
    * `kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d`  
> [!NOTE]
> Both tokens can be revoked or cleaned up by deleting the associated ServiceAccount.

**Configuring Ingress:**

1. Ensure Kong is configured as your Ingress controller.
2. Update the _dashboard-ingress.yaml_ file:
   - Replace the placeholder _YourDashboardHostname_ with the specific hostname for your Kubernetes Dashboard.
3. Apply the updated Ingress configuration: `kubectl apply -f dashboard-ingress.yaml`
4. To access the dashboard, open your browser and visit: _YourDashboardHostname_

**References**

- You can check the [Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-an-api-token-for-a-serviceaccount) for information on creating API tokens for a ServiceAccount, including [long-lived API tokens](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-a-long-lived-api-token-for-a-serviceaccount).
- For more details: [Kubernetes Dashboard Documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
