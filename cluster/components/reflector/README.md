### Setting up Reflector

1. Install Reflector using `kubectl apply -f https://github.com/emberstack/kubernetes-reflector/releases/latest/download/reflector.yaml`

## How to use the reflector?

1. Add the following annotation to the resources which you want to replicate across namepsaces

```
annotations:
    reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
    reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
```

Note:

1. Reflector is a Custom Kubernetes controller that can be used to replicate secrets, configmaps and certificates.

