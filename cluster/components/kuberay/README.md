# KubeRay Dashboard Setup
This guide provides step-by-step instructions to set up the Kubernetes Dashboard, including running an application on a RayCluster.

**Setting up Dashboard:**

1. Deploy a KubeRay operator

    ```
    helm repo add kuberay https://ray-project.github.io/kuberay-helm/ 
    helm repo update

    # Install both CRDs and KubeRay operator v1.2.2.
    helm install kuberay-operator kuberay/kuberay-operator --version 1.2.2 

    # Confirm that the operator is running in the namespace `default`.
    kubectl get pods
    # NAME                                READY   STATUS    RESTARTS   AGE
    # kuberay-operator-7fbdbf8c89-pt8bk   1/1     Running   0          27s
    ```

2. Install a RayService
    ```
    kubectl apply -f https://raw.githubusercontent.com/ray-project/kuberay/v1.2.2/ray-operator/config/samples/ray-service.sample.yaml
    ```
3. Verify the Kubernetes cluster status 
    ```
    # Step 3.1: List all RayService custom resources in the `default` namespace.
    kubectl get rayservice

    # [Example output]
    # NAME                AGE
    # rayservice-sample   2m42s

    # Step 3.2: List all RayCluster custom resources in the `default` namespace.
    kubectl get raycluster

    # [Example output]
    # NAME                                 DESIRED WORKERS   AVAILABLE WORKERS   STATUS   AGE
    # rayservice-sample-raycluster-6mj28   1                 1                   ready    2m27s

    # Step 3.3: List all Ray Pods in the `default` namespace.
    kubectl get pods -l=ray.io/is-ray-node=yes

    # [Example output]
    # ervice-sample-raycluster-6mj28-worker-small-group-kg4v5   1/1     Running   0          3m52s
    # rayservice-sample-raycluster-6mj28-head-x77h4             1/1     Running   0          3m52s

    # Step 3.4: List services in the `default` namespace.
    kubectl get services

    # NAME                                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                   AGE
    # ...
    # rayservice-sample-head-svc                    ClusterIP   10.96.34.90     <none>        10001/TCP,8265/TCP,52365/TCP,6379/TCP,8080/TCP,8000/TCP   4m58s
    # rayservice-sample-raycluster-6mj28-head-svc   ClusterIP   10.96.171.184   <none>        10001/TCP,8265/TCP,52365/TCP,6379/TCP,8080/TCP,8000/TCP   6m21s
    # rayservice-sample-serve-svc                   ClusterIP   10.96.161.84    <none>        8000/TCP                                                  4m58s
    ```

**Setting up Dashboard Ingress:**

1. Apply the ingress to expose dashboard to public users `kubectl apply -f ingress.yaml` (please update the host as needed in ingress.yaml, it is assumed that Kong has been setup)

**Send requests to the Serve applications by the Kubernetes serve service**

```
# Step 1: Run a curl Pod.
kubectl run curl-alpine --image=alpine:latest --restart=Never --tty -i -- sh

apk add --no-cache curl

# Step 2: Send a request to the fruit stand app.
curl -X POST -H 'Content-Type: application/json' rayservice-sample-serve-svc:8000/fruit/ -d '["MANGO", 2]'
# [Expected output]: 6

# Step 3: Send a request to the calculator app.
curl -X POST -H 'Content-Type: application/json' rayservice-sample-serve-svc:8000/calc/ -d '["MUL", 3]'
# [Expected output]: "15 pizzas please!"
```

**Clean up the Kubernetes cluster**

```
# Delete the RayService.
kubectl delete -f https://raw.githubusercontent.com/ray-project/kuberay/v1.2.2/ray-operator/config/samples/ray-service.sample.yaml

# Uninstall the KubeRay operator.
helm uninstall kuberay-operator

# Delete the curl Pod.
kubectl delete pod curl-alpine
```

**References**

- For more information, visit [here](https://docs.ray.io/en/master/cluster/kubernetes/getting-started/rayservice-quick-start.html)
