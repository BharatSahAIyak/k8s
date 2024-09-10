#!/bin/bash

# Set variables
WEBHOOK_URL=$1
USER_ID=$2

# Check if both arguments are provided
if [[ -z "$WEBHOOK_URL" || -z "$USER_ID" ]]; then
  echo "Usage: $0 <YourWebhookUrl> <UserId>"
  exit 1
fi

# Create the updated config map using sed to replace placeholders
sed "s|<YourWebhookUrl>|${WEBHOOK_URL}|g; s|<@UserId>|<@${USER_ID}>|g" argocd-notifications-cm-template.yaml > argocd-notifications-configmap.yaml

# Delete the existing ConfigMap if it exists
kubectl delete cm argocd-notifications-cm -n argocd --ignore-not-found

# Apply the newly created ConfigMap
kubectl apply -f argocd-notifications-configmap.yaml