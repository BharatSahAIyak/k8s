### Setting up ArgoCd Ingress

1. Enable insecure requests in argocd `kubectl apply -f argocd-cmd-params-cm.yaml`
2. Restart argocd-server for the config changes to reflect `kubectl rollout restart deployment argocd-server -n argocd`
3. Apply the ingress to expose argocd to public users `kubectl apply -f ingress.yaml` (please update the host as needed in ingress.yaml, it is assumed that Kong has been setup)

### Setting up a argocd repository secret

1. Run `kubectl apply -f vault-auth.yaml` to setup VaultAuth for argocd namespace
2. Run `kubectl apply -f k8s-repository.yaml` to create configure private k8s repository in argocd

### Extracting ArgoCD Password

1. `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode`

> [!NOTE]
> 1. ArgoCD is installed as a part of cluster