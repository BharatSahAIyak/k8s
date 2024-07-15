### Steps to Setup Vault

1. `helm repo add hashicorp https://helm.releases.hashicorp.com`
2. `help update`
3. `kubectl create namespace vault`
4. `kubectl apply -f sa.yaml`
5. Navigate to stateful machine and exec into Vault
7. Run `export VAULT_ADDR="http://127.0.0.1:8200"`
8. Run `vault auth enable kubernetes`
9. Run `kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode` on cluster and set value of this in variable `cert` inside vault
10. Run `kubectl get secret vault-auth-secret -n vault --output 'go-template={{ .data.token }}' | base64 --decode` on cluster and set value as `jwt` in Vault
11. Run `vault write auth/kubernetes/config token_reviewer_jwt="$jwt" kubernetes_host="https://10.10.1.6:6443" kubernetes_ca_cert="$cert"`
12. Run `vault write auth/kubernetes/role/vault-auth bound_service_account_names=default bound_service_account_namespaces='*' policies='admin-policy'` (ensure admin policy exists in vault and this policy has permissions to access the secrets you try to sync)
13. Navigate back to the K8S admin machine
14. Run `helm install vault hashicorp/vault-secrets-operator -n vault --values vault-values.yaml` (ensure to update the address that points to Vault)
15. Run `kubectl apply -f vault-auth.yaml` (needs to be done in each namepsace, allows the namespace to authenticate with Vault)
16. Run `kubectl apply -f sample-secret.yaml` (creates a sample secret that syncs a secret from Vault, ensure the path mentioned in sample-secret.yaml exists in Vault)

### How to verify if Vault is setup properly?

1. Run `kubectl describe VaultStaticSecret sample-secret`
2. If you see an event with message `Secret synced`, the setup is successful. 



