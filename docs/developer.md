## Onboarding a Service

1. Building Image for the Service

    1. Add [this](https://github.com/Samagra-Development/devops/blob/main/examples/workflows/build-and-push.yaml) action in the service reposiotry at `.github/workflows/build-and-push.yaml`

        Note: 
        
        1. This actions get triggered whenever you push to the main/dev branch or you create a release, and builds and pushes image to ghcr

        2. Ensure to verify that the action has succeeded before redeploying a service

    2. Use `cli.sh` to onboard the service. 

## Management of a Service - [Video](https://drive.google.com/file/d/1xBJEpFBi90L72OEA7GSjdNyNk4Pb9PQB/view)

1. Updating the tag of image in any environment

    1. Naviagte to [kustomize/overlays](https://github.com/BharatSahAIyak/k8s/tree/v2/kustomize/overlays) and edit `<environment>/kustomization.yaml` (e.g., `bhasai-dev/kustomization.yaml`)

    2. Add a new block called images or add a new entry in existing images block as follows

    ```
    images:
      - name: <image-url>
        newTag: <tag>

    e.g.,

    images:
      - name: ghcr.io/bharatsahaiyak/orchestrator
        newTag: 0.5.0 
    ```

2. Updating the environment variables of any service

    1. Navigate to the [vault](https://vault.k8s.bhasai.samagra.io/ui/)

    2. Navigate to the environment (e.g., `bhasai-dev`) for which you want to update the environment variable

    3. Naviagte to the folder of the service for which you want to the update the environment variable

    Note: 
    1. Request for the access of the environment from DevOps Team if you see permission errors

    2. Ensure to restart the service from ArgoCD for the environment variables to reflect in the service

3. Viewing Logs of a Service

    1. Navigate to [ArgoCD](https://ci.k8s.bhasai.samagra.io/)

    2. Navigate to the environment you want to view logs of Service

    3. Seach for the service and click on 3 dots and click on Logs to view logs

4. Restarting a Service

    1. Navigate to [ArgoCD](https://ci.k8s.bhasai.samagra.io/)

    2. Navigate to the environment you want to view logs of Service

    3. Seach for the service and click on 3 dots and click on restart to restart the service

    Note: Restarting a deployment pulls the image and then recreates the containers

## Frequently Asked Questions (FAQ)

1. What to do when i see service is down on admin?

    Admin shows whether service is down or up on basis of the health check. The first step should be to hit the health endpoint of the respective service manually to see what is failing in health check and then debug further basis on what is failing. 

2. What to do when I see `failure to get a peer from the ring balancer`?

    This happens when the gateway is not able to find any upstream container catering to the requests. You can go on ArgoCD and verify if the container is started.

3. What to do when i am getting `504 Gateway Timeout Error`?

    We have a default 60 seconds timeout on the API Gateway. You will get this error when upstream service fails to respond within 60 seconds. You can check logs of the service to debug.

4. What to do when i see `500 Internal Server Error`?

    This comes when something inside the service breaks. You can check logs of the service to debug.

5. How to know what image tag of a service is deployed in any environment?

    - Go to deployment object of the service in ArgoCD and open details
    - Search for image and you will find the url of image (it will show in `Live Manifest` tab)
