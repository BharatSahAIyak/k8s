# Kubernetes Dashboard Setup

This guide provides step-by-step instructions to set up the Kubernetes Dashboard, including obtaining Bearer Tokens for authentication.

**Setting up Dashboard:**

1. Add the Kubernetes Dashboard Helm repository: `helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/`
2. Install or upgrade the Kubernetes Dashboard release: `helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard -f values.yaml --create-namespace --namespace kubernetes-dashboard`

**Setting up Dashboard Ingress:**

1. Apply the ingress to expose dashboard to public users `kubectl apply -f ingress.yaml` (please update the host as needed in ingress.yaml, it is assumed that Kong has been setup)

**Setting up Authentication Token**

1. Setting up User with relevant permissions

    1. Create a Service Account: `kubectl apply -f service-account.yaml`
    2. Create a Cluster Role Binding: `kubectl apply -f cluster-role-binding.yaml`

2. Generating token for the User

    1. Creating a Temporary Bearer Token (expires in 1 hr)
    
    * `kubectl -n kubernetes-dashboard create token admin-user`  

    2. Creating a Permanent Bearer Token

    * `kubectl apply -f service-account-token.yaml`   
    * `kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d`  

> [!NOTE]
> The bearer tokens can be revoked by deleting the associated ServiceAccount using below command:  
`kubectl delete serviceaccount admin-user -n kubernetes-dashboard`

**References**

- For more information, visit [here](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
