# Kubernetes Dashboard Setup

This guide provides step-by-step instructions to set up the Kubernetes Dashboard, including obtaining Bearer Tokens for authentication.

**1. Install the Kubernetes Dashboard Using Helm**

Add the Kubernetes Dashboard Helm repository: `helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/`

Install or upgrade the Kubernetes Dashboard release: `helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -f values.yaml --create-namespace --namespace kubernetes-dashboard`

**2. Create a Service Account**: `kubectl apply -f dashboard-adminuser.yaml`

**3. Create a Cluster Role Binding**: `kubectl apply -f dashboard-clusterrolebinding.yaml`

**4. Create a Temporary Bearer Token**: `kubectl -n kubernetes-dashboard create token admin-user`  
⚠ Expires in one hour. To revoke, delete the ServiceAccount.

or

**Create a Long-Lived Bearer Token**:   
`kubectl apply -f dashboard-adminuser-secret.yaml`   
`kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d`  
⚠ Automatically cleaned up when the ServiceAccount is deleted.

**5. Access the Dashboard via Ingress** `kubectl apply -f dashboard-ingress.yaml`  
Visit _dashboards.k8s.io_ in your browser and log in with the Bearer Token.

**References**

- You can check the [Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-an-api-token-for-a-serviceaccount) for information on creating API tokens for a ServiceAccount, including [long-lived API tokens](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-a-long-lived-api-token-for-a-serviceaccount).
- For more details: [Kubernetes Dashboard Documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
