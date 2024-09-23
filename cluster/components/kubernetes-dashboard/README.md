# Kubernetes Dashboard Setup

This guide provides step-by-step instructions to set up the Kubernetes Dashboard, including obtaining Bearer Tokens for authentication.

**1. Install the Kubernetes Dashboard Using Helm**

Add the Kubernetes Dashboard Helm repository:

```bash
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
```

Install or upgrade the Kubernetes Dashboard release:

```bash
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -f values.yaml --create-namespace --namespace kubernetes-dashboard
```

**2. Create a Service Account**

```bash
kubectl apply -f dashboard-adminuser.yaml
```

**3. Create a Cluster Role Binding**

```bash
kubectl apply -f dashboard-clusterrolebinding.yaml
```

**4. Get a Bearer Token**

**Temporary Bearer Token**

The token has a lifespan of one hour from its creation time.
```bash
kubectl -n kubernetes-dashboard create token admin-user
```
* **Note:**         
   The token expires automatically after one hour. To revoke it immediately, delete the service account:

   ```bash
   kubectl -n kubernetes-dashboard delete serviceaccount admin-user
   ```

   ⚠ **Warning:** This will revoke the token and associated permissions. If you prefer not to delete the service account, continue with the steps below.
   
* Check [Kubernetes docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-an-api-token-for-a-serviceaccount) for more information about API tokens for a ServiceAccount.


**Long-Lived Bearer Token**

1. **Create a Secret for the `admin-user` ServiceAccount**

   ```bash
   kubectl apply -f dashboard-adminuser-secret.yaml
   ```

* **Note :**  
 When you delete a ServiceAccount that has an associated Secret, the Kubernetes control plane automatically cleans up the long-lived token from that Secret.
 
* Check [Kubernetes docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#manually-create-a-long-lived-api-token-for-a-serviceaccount) for more information about long-lived API tokens for a ServiceAccount.

2. **Retrieve the Token from the Secret**

   ```bash
   kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
   ```

**5. Access the Dashboard**

Forward the Kubernetes Dashboard service to your local port:

```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

Open your web browser and navigate to:

```
https://localhost:8443/#/login
```

Use the Bearer Token (obtained in Step 4) to log in.

To access the Kubernetes Dashboard using Ingress, follow these steps:

### Access the Dashboard via Ingress

1. **Apply the Ingress Configuration**

   Ingress resource is defined in `dashboard-ingress.yaml`. It should route traffic to the Kubernetes Dashboard service. Apply the Ingress configuration:

   ```bash
   kubectl apply -f dashboard-ingress.yaml
   ```

2. **Access the Dashboard**

   Open your web browser and navigate to:

   ```
   dashboards.k8s.io
   ```

3. **Log In**

   Use the Bearer Token to log in.

**References**

- [Kubernetes Dashboard Documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)


