## Pre-requisites

1. Install Reflector using `kubectl apply -f https://github.com/emberstack/kubernetes-reflector/releases/latest/download/reflector.yaml`

## Steps to replicate a resource across all namepsaces

1. Add the following annotation to the resources which you want to replicate across namepsaces

```
annotations:
    reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
    reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
```