# ArgoCD Notifications :

**This documentation will enable you to send notifications from ArgoCD for successful syncs to Discord**

Steps :

* Go to a discord channel and click on `Server Settings`->`Integrations`->`Webhooks`, and create a webhook

* `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/manifests/install.yaml`

* `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/catalog/install.yaml`

* `vi argocd-notifications-configmap.yaml`
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  # Define the webhook service
  service.webhook.discord: |
    url: "<your-webhook-url>"
    headers:
      - name: Content-Type
        value: application/json

  # Template for sync succeeded notifications
  template.app-sync-succeeded: |
    webhook:
      discord:
        method: POST
        body: |
          {
            "username": "{{.app.metadata.name}}",
            "content": "Application {{.app.metadata.name}} is now running new version of deployment manifests.\\nURL: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}\\nContext: continuous-delivery/{{.app.metadata.name}}"
          }

  # Trigger on successful sync
  trigger.on-sync-succeeded: |
    - description: Application syncing has succeeded
      send:
        - app-sync-succeeded
      when: app.status.operationState.phase in ['Succeeded']
```

* `kubectl delete cm argocd-notifications-cm -n argocd` (If already present)

* `kubectl apply -f argocd-notifications-configmap.yaml`

* `kubectl get cm argocd-notifications-cm -n argocd -o yaml`

* `kubectl rollout restart deployment argocd-notifications-controller -n argocd`

* `kubectl logs -n argocd deployment/argocd-notifications-controller`


**When your ArgoCD will sync the changes then you will get a notification on the specified discord channel.**