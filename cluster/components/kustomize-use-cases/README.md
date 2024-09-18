# Kustomize Use Cases

### Applying Patch for Replicas and Resources in Kustomize

This guide provides steps to update Kubernetes _Deployment_ replicas and resource requests/limits, including GPU allocation, using Kustomize. You can also modify other objects similarly.

**Patch Overview**

The provided patch modifies:

- **Replicas**: Number of pod replicas.
- **Resources**: Memory and GPU requests/limits.

**Applying the Patch with Kustomize**

1. Go to the desired overlay directory:   
`cd kustomize/overlays/<EnvironmentName>/kustomization.yaml`
2. Copy and modify the code in the provided _kustomization.yaml_ file. Include the patch code in the _overlays/EnvironmentName/kustomization.yaml_ file.

**Conclusion**

By using Kustomize patches, you can easily manage and modify your Kubernetes deployments without altering the base resources directly.

