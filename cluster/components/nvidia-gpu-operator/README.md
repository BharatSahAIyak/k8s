### Setting up Nvidia GPU Operator

1. Add nvidia helm repo `helm repo add nvidia https://helm.ngc.nvidia.com/nvidia`
2. Update Helm Repos `helm repo update`
3. Install Nvidia GPU Operator `helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator --set nfd.enabled=false`
4. For more, refer [this](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html)

### Setting up Metrics Ingress:

1. Apply the ingress to expose _/metrics_ endpoint to public users: `kubectl apply -f ingress.yaml` (please update the host as needed in ingress.yaml, it is assumed that Kong has been setup)

### Configure GPU Sharing

1. Add a config map to the namespace that is used by the GPU operator `kubectl create -n gpu-operator -f time-slicing-config-all.yaml`
2. Configure the cluster policy so that the device plugin uses the config map `kubectl patch clusterpolicies.nvidia.com/cluster-policy -n gpu-operator --type merge -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-all", "default": "any"}}}}'`
3. For more, refer [this](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html)