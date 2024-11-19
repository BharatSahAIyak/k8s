# Kustomize use cases :
We want to be able to modify the values like replicas, requests, limits etc for each service in particular overlays.

**Lets take an example : We want to change the replica, requests, limits value of service named _base/text-translation-azure-dict_ in overlays/bhasai-prod.**

Follow the steps :

* In _text-translation-azure-dict/text-translation-azure-dict.yaml_ file add the contents of _Configmap.yaml_ at the top.

* In the overlays/bhasai-prod/kustomization.yaml add the contents of _Replacement.yaml_ at the bottom.

* Now at the _overlays/bhasai-prod_ level in the terminal run: `kustomize build . > output.yaml`

* Verify the outpu.yaml file for replacements.