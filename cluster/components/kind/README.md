# Creating the vm :

1. Use the below image for creating the ubuntu vm :
```https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04-live-server-arm64.iso```

# Creating the cluster :

1. Use the cluster-config.yaml file for creating cluster.

2. Create the cluster using the following command: ```kind create cluster --name <Name for the cluster> --config ./cluster-config.yaml```

# Setting up docker, vault and caddy on Vm:
1. Follow the below repo to setup docker, vault and caddy:
```https://github.com/Samagra-Development/devops.git```

Make add the following changes for vault's docker-compose.yaml :
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
      VAULT_LOG_LEVEL: "trace"```
Make add the following changes for caddy's docker-compose.yaml :```
network_mode: host
```

Make sure to use the network_mode as "host":
```network_mode : host```


# Setting up vault :

Follow this : [Setting up Vault](../vault/README.md)

Make sure :

1. In vault-values.yaml: ```
address: "http://<VM's IP>:<Vault's port, eg 
: 8200>"```
2. Make changes accordingly in this command :```vault write auth/kubernetes/config token_reviewer_jwt="$jwt" kubernetes_host="https://<Node's Internal IP>:6443" kubernetes_ca_cert="$cert" ```

# Setting up kong :

Follow this to setup kong : [Setting up kong](../kong/README.md)