# Overview:
In the below steps you will be creating a Virtual Machine on you local system. Firstly, on Virtual Machine you will be installing docker, Vault and Caddy using the "devops" repo given below. On your  VM install kind, kubectl  then create a Cluster using kind. After the cluster is created follow the steps to setup vault and kong.
At the end will:
- When You will hit the domain name configured from your local system then it will take you to kong-gateway-proxy which is configured on the cluster. 
- Another part is that you should also be able to sync the secrets from Vault.

# Creating the Virtual Machine (VM) :
You can use UTM(Link is for macOS: https://mac.getutm.app/) to create the VM.

1. Use the below image for creating the ubuntu vm :
```https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04-live-server-arm64.iso```

2. Shutdown the VM. Create and use a Bridge network in the settings for the VM.


# Installing docker, vault and Caddy on Vm:
1. Fork and clone the fork of the following repo to setup docker, vault and caddy: ```https://github.com/Samagra-Development/devops.git```
Follow the steps(Upto step 9) under : "Setting up services on VM". 

2. In the .env file add the following details:
![valut, caddy credentials](./ss/initial.png)


3. Make the following changes for vault's docker-compose.yaml(/home/username/devops/common/environment/docker-compose.yaml) (Leave the rest as it is):![Example for Vault's docker-compose.yaml](./ss/vault.png)
``` 
volumes:
  environment:

services:
  environment:
    ports:
      - "8200:8200"
    build:
      context: .
      dockerfile: Dockerfile
    restart: always
    network_mode: host
    environment:
      VAULT_USERNAME: ${ENVIRONMENT_USERNAME:?ENVIRONMENT_USERNAME is not set}
      VAULT_PASSWORD: ${ENVIRONMENT_PASSWORD:?ENVIRONMENT_PASSWORD is not set}
      VAULT_LOG_LEVEL: "trace"
``` 

4. Make the following changes for caddy's docker-compose.yaml (/home/username/devops/common/caddy/docker-compose.yaml):```network_mode: host``` ![Example for caddy's docker-compose.yaml](./ss/caddy.png)

Make sure to use the network_mode as "host":```network_mode : host```

5. Only uncomment the service in docker-comopose file which you want to use, like :
![Uncomment services in docker-compose.yaml](./ss/uncomment.png)

Use the ```make deploy```command

# Creating the cluster using kind :

1. Install kind on your local machine: https://kind.sigs.k8s.io/docs/user/quick-start/ 

2. Install kubectl on local: https://kubernetes.io/docs/tasks/tools/

3. Use the docs/local-cluster/cluster-config.yaml file of this repository for creating cluster.

2. Create the cluster using the following command: ```kind create cluster --name <Name for the cluster> --config ./cluster-config.yaml```


# Setting up vault :

Follow this : [Setting up Vault](../../cluster/components/vault/README.md)

Make sure :
1. In vault-values.yaml: ```
address: "http://<VM's IP>:<Vault's port, eg 
: 8200>"```

eg : ```"http://192.168.64.1:8200```

To get ip address of VM, type : ```ip a```

Go to the Vault's UI using <VM's IP>:8200 and In Secrets Engine "kv" create a secret called "sample-secret" with a key eg : a with value b

2. Make changes accordingly in this command(Step 10th) :```vault write auth/kubernetes/config token_reviewer_jwt="$jwt" kubernetes_host="https://<Node's Internal IP>:6443" kubernetes_ca_cert="$cert" ```

3. To get INTERNAL_IP of node type : ```kubectl get nodes -o wide```

# Setting up kong :

Follow this to setup kong : [Setting up kong](../../cluster/components/kong/README.md)


![kong's svc](./ss/kong-svc.png)


# Configure Caddy and Reload it: 

1. Cd into the devops repository which you used to setup Caddy.

2. Configure the Caddy file at root level. Use the Node's Internal IP. 
![kong's svc](./ss/caddy-config.png)

```
#import ./common/monitoring/Caddyfile
#import ./common/minio/Caddyfile
#import ./common/environment/Caddyfile
#import ./common/fusionauth/Caddyfile
# The registry doesn't have a auth thus exposing it publicly means anyone can access the images pushed to this registry
#import ./common/registry/Caddyfile

{$DOMAIN_SCHEME}://{$DOMAIN_NAME} {
    reverse_proxy <Nodes's Internal IP>:32001
}
```

3. Go to your Local machine's /etc/hosts file and add eg : ```192.168.64.1 k8s.local``` 

4. On VM To reload Caddy type :```make down``` then ```make deploy```

5. Now when you will hit ```k8s.local``` from local machine's browser the you should get something like below: ![kong's gateway](./ss/kong-gateway.png)