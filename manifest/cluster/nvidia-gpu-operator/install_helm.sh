#!/bin/env bash
set -ex
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && helm repo update

helm install --wait gpu-operator \
     -n gpu-operator --create-namespace \
      nvidia/gpu-operator \
      --set driver.enabled=false \
      --set toolkit.enabled=false
