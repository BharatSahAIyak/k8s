# ArgoCD Notifications :

**This documentation will enable you to send notifications from ArgoCD for successful syncs & when the health status of an individual application is degraded or in a failed state.**

Pre-requisites :
* Make sure to enable Develpoer mode in Discord.
    * Go to User Settings->Advanced->Developer mode.
    * To copy any user's ID, Right click on a user and click _COPY User ID_

Steps :

* Go to a discord channel and click on `Server Settings`->`Integrations`->`Webhooks`, and create a webhook

* Copy the Webhook URL somewhere, it will be used later.

* `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/manifests/install.yaml`

* `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/catalog/install.yaml`


* Pass the Value of _WEBHOOK_URL_ and _USER_ID_ after the command: `./argocd_notifications_setup.sh`
    * e.g. ./argocd_notifications_setup.sh "https://discord.com/api/webhooks/1280" "75795430"

* Add this in your application.yaml's metadata section
    * 
    ```
      annotations:
        notifications.argoproj.io/subscribe.on-health-degraded.discord: ""
        notifications.argoproj.io/subscribe.on-sync-failed.discord: ""
        notifications.argoproj.io/subscribe.on-sync-succeeded.discord: ""
    ```

* kubectl apply -f application.yaml

* kubectl rollout restart deployment argocd-notifications-controller -n argocd

* kubectl logs -n argocd deployment/argocd-notifications-controller

**When your ArgoCD will sync the changes then you will get a notification on the specified discord channel.**

**If the health gets degraded then also you will recieve a notification on the specified discord channel**