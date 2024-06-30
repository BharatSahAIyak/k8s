#!/bin/env bash

kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -f vaules.yml --create-namespace --namespace argocd

# wget https://github.com/argoproj/argo-cd/releases/download/v2.11.3/argocd-linux-amd64