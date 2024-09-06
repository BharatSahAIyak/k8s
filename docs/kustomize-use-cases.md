# Kustomize use cases :
### Lets take an example : We want to change the replica, requests, limits, gpu value of service named `ner` in bhasai-dev.

Follow the steps :

* `cd bhasai-dev`
* `mkdir patches`
* `cd patches`
* Create `ner-patch.yaml` file with below code
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ner
spec:
  replicas: 3 
  template:
    spec:
      containers:
        - name: ner
          resources:
            requests:
              memory: "74Mi"
            limits:
              memory: "87Mi" 
              nvidia.com/gpu: "2" 

   ```
* `cd ..`
* `vi kustomization.yaml` and at last of code,  add :
```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
patches:
- path: patches/ner-patch.yaml
```
* `kustomize build . > output.yaml` and check the output.yaml file for desired changes.
