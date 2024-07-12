Steps to Install Kustomize

1. `curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash`
2. `sudo cp kustomize /usr/local/bin/`

Steps to deploy a new environment

1. Make a copy of any of your existing environments
2. Update the name of namespace in namespace.yaml and kustomization.yaml
3. Run `kubectl build <location-of-folder-of-environment>` to verify the resources being generated
4. Run `kubectl apply -k <location-of-folder-of-environment>` to apply the resources 
