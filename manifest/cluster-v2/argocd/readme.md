Steps

1. Enable argocd addon in kubespray at `group_vars/k8s_cluster/addons.yml`

```
argocd_enabled: true
argocd_version: v2.11.0
argocd_namespace: argocd
```

2. Appply configmap with insecure option

```
kubectl apply -f argocd-cmd-params-cm.yaml
```

3. Restart Deployment

```
kubectl rollout restart deployment argocd-server -n argocd
```

4. Get the password

```
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
```
