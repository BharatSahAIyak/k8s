# ArgoCD Notifications :

### This doc explains the approach followed till now. And is not "currently" a stepwise guide for enabling notifications of ArgoCD.

Currently I am able to send notifications for successful syncs but not the when argocd's health is degraded.

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/manifests/install.yaml

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/catalog/install.yaml 


`vi argocd-notifications-configmap.yaml`
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  # Define the webhook service
  service.webhook.discord: |
    url: "https://discord.com/api/webhooks/1280763657323548754/pmcCsHwZFajfRS4As-zkoZr8EWewEz3YDoNPuQ-iN7tkGGAKboqlIWcOworDQsNYtKWh"
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

`kubectl delete cm argocd-notifications-cm -n argocd` (If already present)

`kubectl apply -f argocd-notifications-configmap.yaml`

`kubectl get cm argocd-notifications-cm -n argocd -o yaml `

`kubectl rollout restart deployment argocd-notifications-controller -n argocd`

`kubectl logs -n argocd deployment/argocd-notifications-controller`


**Updated argocd-notifications-configmap.yaml**

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  # Define the webhook service
  service.webhook.discord: |
    url: "https://discord.com/api/webhooks/1280763657323548754/pmcCsHwZFajfRS4As-zkoZr8EWewEz3YDoNPuQ-iN7tkGGAKboqlIWcOworDQsNYtKWh"
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

  # Template for degraded or down notifications
  template.app-degraded: |
    webhook:
      discord:
        method: POST
        body: |
          {
            "username": "{{.app.metadata.name}}",
            "content": "Application {{.app.metadata.name}} is currently degraded or down.\\nURL: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}\\nContext: continuous-delivery/{{.app.metadata.name}}"
          }

  # Trigger on degraded or down state
  trigger.on-degraded: |
    - description: Application is in a degraded or down state
      send:
        - app-degraded
      when: app.status.operationState.phase in ['Degraded', 'Failed']
```
`Reference for above code :` https://argocd-notifications.readthedocs.io/en/stable/catalog/

Modified : `template.app-degraded` to `template.app-health-degraded`
& 
`trigger.on-degraded` to `trigger.on-health-degraded`
