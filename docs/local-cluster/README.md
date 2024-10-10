# Kind Cluster Setup

By the end of this setup, you will be able to:

* Access the _kong-gateway-proxy_ service from your local machine using a domain name configured with Caddy.
* Synchronize secrets from Vault to your Kubernetes cluster, ensuring secure and efficient management of sensitive data.

### Creating the Virtual Machine (VM):  

- _macOS_: Use [UTM](https://mac.getutm.app/) to create the VM.
- _Windows/Linux_: Use [Oracle VM VirtualBox](https://www.oracle.com/in/virtualization/technologies/vm/downloads/virtualbox-downloads.html) or another virtualization tool compatible with your OS.

1. Download the Ubuntu Image: [Ubuntu 24.04 Live Server ARM64](https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04-live-server-arm64.iso).
2. Configure the VM: Set up a Bridge network to allow the VM to communicate directly with your local network, enabling access to external services and devices.

### Installing Docker, Vault, and Caddy on the VM

1. Clone the Repository: _git clone https://github.com/Samagra-Development/devops.git_  
Follow the steps (up to step 9) under "Setting up services on VM.

2. Configure Environment Variables: Update .env file as follows, leave rest as it is.
   ```
   DOMAIN_NAME='k8s.local'
   DOMAIN_SCHEME='http'
   ENVIRONMENT_USERNAME='admin'
   ENVIRONMENT_PASSWORD='admin'
   ```

3. Modify Vault's Docker Compose Configuration: Edit `/home/username/devops/common/environment/docker-compose.yaml` to include _ports_ & _network_mode_, leave rest as it is:
    ```yaml
    services:
        environment:
            ports:
                - "8200:8200"
            network_mode: host
    ```

4. Update Caddy's Docker Compose Configuration: In the file _/home/username/devops/common/caddy/docker-compose.yaml_, add the line _network_mode: host_, keeping the rest of the file unchanged.

5. Uncomment Desired Services: In the _/home/username/devops/docker-compose.yaml_, uncomment only the services you intend to use.

6. Deploy Services: Use the following command to deploy the services: `make deploy`

### Creating the Cluster Using Kind:

1. [Install kind on your local machine](https://kind.sigs.k8s.io/docs/user/quick-start/)
2. [Install kubectl on local](https://kubernetes.io/docs/tasks/tools/)
3. [Install Helm on local machine](https://helm.sh/docs/intro/install/#from-apt-debianubuntu)
4. Use the _docs/local-cluster/cluster-config.yaml_ file of this repository for creating the cluster.
5. Create the cluster using the following command: (Replce _YourClusterName_ as desired)  
   ```kind create cluster --name YourClusterName --config ./cluster-config.yaml```

### Setting up vault :

Follow the instructions in the: [Setting up Vault](../../cluster/components/vault/README.md)
All necessary files are located in the same directory as the README.md in this repository.

Ensure the following:

1. Update the Kubernetes Configuration: In the command from Step 10, replace <Node's Internal IP> :```vault write auth/kubernetes/config token_reviewer_jwt="$jwt" kubernetes_host="https://<Node's Internal IP>:6443" kubernetes_ca_cert="$cert" ```
    -  To get node's internal IP of node type : ```kubectl get nodes -o wide```

2. Modify Vault's Address: Before Step 13, update the _vault-values.yaml_ file to set the _address_ as follows:   
`address: "http://<VM's IP>:<Vault's port, eg 
: 8200>"`  eg : `"http://192.168.64.1:8200`
   - To get ip address of VM, type : ```ip a```

3. Access Vault's UI:
   * Navigate to _http://<VM's IP>:8200_ in your browser.
   * In the "kv" Secrets Engine, create a secret named "sample-secret" with the following details:
     - Key: (e.g., `a`)
     - Value: (e.g., `b`)
   * After creating the secret, proceed to run Step 15th.

4. Follow the provided steps to verify that the secrets have been successfully synchronized.

### Setting up kong :

Follow the instructions in the: [Setting up kong](../../cluster/components/kong/README.md)guide. 
All necessary files are located in the same directory as the README.md in this repository.

To verify the services, run: ```kubectl get svc -n kong```

### Configure Caddy and Reload It

1. Navigate to the devops repository used for setting up Caddy.
2. Update the root-level Caddyfile located at /home/username/devops/Caddyfile by adding the following configuration, replacing <Node's Internal IP> with the actual internal IP address:

   ```
   {$DOMAIN_SCHEME}://{$DOMAIN_NAME} {
       reverse_proxy <Node's Internal IP>:32001
   }
   ```
3. On your local machine, edit the _/etc/hosts_ file to add the following line, replacing _<VM's IP>_ with the actual IP address of your VM:

    ```
    <VM's IP> k8s.local
    ```

4. To reload Caddy on the VM, run:
   ```bash
   make down
   make deploy
   ```
5. Now, when you access _k8s.local_ from your local machine's browser, you should see the Kong Gateway interface.

