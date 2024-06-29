#!/bin/env bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

kubectl apply -f vault-service-account.yml 
# setup role in vault in stateful
helm install vault hashicorp/vault-secrets-operator -n vault --create-namespace --values vault-values.yaml
kubectl apply -f static-secret.yaml
