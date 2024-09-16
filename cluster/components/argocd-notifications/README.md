# ArgoCD Notifications

This guide will help you set up ArgoCD to send notifications for:
* Successful syncs
* When the health status of an application is degraded or failed


### Prerequisites

* Enable Developer mode in Discord:
    * Navigate to `User Settings` -> `Advanced` -> `Developer mode`.
* Right-click on a user and select _Copy User ID_ to obtain the user ID.

### Steps:

1. Go to a discord channel and click on `Server Settings`->`Integrations`->`Webhooks`, and create a webhook

2. Copy the Webhook URL; you will need it later.

3. Install the Argo CD Notifications controller:
    ```bash
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/manifests/install.yaml
    ```
    * This command deploys the Argo CD Notifications controller, which handles sending notifications for Argo CD application status updates.

4. Install the notification templates and triggers catalog:
    ```bash
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/catalog/install.yaml
    ```
    * This command sets up a catalog of predefined notification templates and triggers, facilitating easier configuration and customization of notifications.

5. Configure the webhook and user ID in the following command:
    ```bash
    WEBHOOK_URL="https://discord.com/api/webhooks/1280"
    USER_ID="75795430"
 
    sed -e "s|WEBHOOK_URL|${WEBHOOK_URL}|g" -e "s|USER_ID|${USER_ID}|g" argocd-notifications-cm-template.yaml > argocd-notifications-configmap.yaml
    ```
    
6. Update the ConfigMap with the new configuration:
    ```bash
    kubectl delete cm argocd-notifications-cm -n argocd --ignore-not-found
    kubectl apply -f argocd-notifications-configmap.yaml
    ```

7. Add annotations to your application configuration's metadata to subscribe to Discord notifications:
    ```yaml
    annotations:
      notifications.argoproj.io/subscribe.on-health-degraded.discord: ""
      notifications.argoproj.io/subscribe.on-sync-failed.discord: ""
      notifications.argoproj.io/subscribe.on-sync-succeeded.discord: ""
    ```

8. Apply the application configuration with notification changes:
    ```bash
    kubectl apply -f application.yaml
    ```

9. Restart the ArgoCD notifications controller to apply the new configuration:
    ```bash
    kubectl rollout restart deployment argocd-notifications-controller -n argocd
    ```

10. Check the logs of the notifications controller to ensure it's running correctly:
    ```bash
    kubectl logs -n argocd deployment/argocd-notifications-controller
    ```