# ArgoCD Notifications :

**This documentation will enable you to send notifications from ArgoCD for successful syncs & when the health status of an individual application is degraded or in a failed state.**

Steps :

* Go to a discord channel and click on `Server Settings`->`Integrations`->`Webhooks`, and create a webhook

* Copy the Webhook URL somewhere, it will be used later.

* `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/manifests/install.yaml`

* `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/catalog/install.yaml`

* `vi argocd-notifications-configmap.yaml`

* `kubectl delete cm argocd-notifications-cm -n argocd` (If already present)

* `kubectl apply -f argocd-notifications-configmap.yaml`

* `kubectl apply -f application.yaml`

* `kubectl get cm argocd-notifications-cm -n argocd -o yaml`

* `kubectl rollout restart deployment argocd-notifications-controller -n argocd`

* `kubectl logs -n argocd deployment/argocd-notifications-controller`


**When your ArgoCD will sync the changes then you will get a notification on the specified discord channel.**

**If the health gets degraded then also you will recieve a notification on the specified discord channel**