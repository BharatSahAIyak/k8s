# Kustomize Use Cases

### Applying Patch for Replicas and Resources in Kustomize

This guide provides steps to update Kubernetes _Deployment_ replicas and resource requests/limits, including GPU allocation, using Kustomize. You can also modify other objects similarly.

**Patch Overview**

The provided patch modifies:

- **Replicas**: Number of pod replicas.
- **Resources**: Memory and GPU requests/limits.



**Example with Placeholders**

Let's say you want to modify the replicas and resource requests/limits for your deployments, including GPU allocation. Here's the format you would use in your _kustomize/overlays/EnvironmentName/kustomization.yaml_ file:

```yaml
patches:
  - patch: |-
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: <ServiceName>
      spec:
        replicas: <ReplicaCount>
        template:
          spec:
            containers:
              - name: <ContainerName>
                resources:
                  requests:
                    memory: "<MemoryRequest>"
                  limits:
                    memory: "<MemoryLimit>"
                    nvidia.com/gpu: "<GPULimit>"
```

**Actual Example**

Let's say you want to increase the replicas for a service named `bff` to 2 and set the memory limit to 2 GB. The patch will look as follows:

```yaml
patches:
  - patch: |-
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: bff
      spec:
        replicas: 2
        template:
          spec:
            containers:
              - name: bff
                resources:
                  requests:
                    memory: "1024Mi"
                  limits:
                    memory: "2048MiGi"
```

**Conclusion**

By using Kustomize patches, you can easily manage and modify your Kubernetes deployments without altering the base resources directly.

To check the correctness of your Kustomize configuration, run `kustomize build .` in the _kustomize/overlays/EnvironmentName_ directory and review the changes.

You can also output the result to a file by running `kustomize build . > output.yaml` to review the final YAML configuration.


Refer to [Kustomize Documentation](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#customizing) for more details.
