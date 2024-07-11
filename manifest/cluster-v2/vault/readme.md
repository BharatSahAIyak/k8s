Steps to Setup Vault

1. Start Vault on the stateful machine
2. `helm repo add hashicorp https://helm.releases.hashicorp.com`
3. `help update`
4. `kubectl create namespace vault`
5. `kubectl apply -f sa.yaml`
6. Navigate back to stateful machine and exec into Vault
7. `export VAULT_ADDR="http://127.0.0.1:8200"`
8. `vault auth enable kubernetes`
9. Run `kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode` on cluster and set value of this in variable `cert` inside vault
10. Run `kubectl get secret vault-auth-secret -n vault --output 'go-template={{ .data.token }}' | base64 --decode` on cluster and set value as `jwt` in Vault
11. `vault write auth/kubernetes/config token_reviewer_jwt="$jwt" kubernetes_host="https://10.10.1.6:6443" kubernetes_ca_cert="$cert"`
12. `vault write auth/kubernetes/role/vault-auth bound_service_account_names=default bound_service_account_namespaces='*' policies='admin-policy'` (ensure admin policy is created)
13. `helm install vault hashicorp/vault-secrets-operator -n vault --values vault-values.yaml`
14. `kubectl apply -f vault-auth.yaml` (needs to be done in each namepsace, allows the namespace to authenticate with Vault)
15. `kubectl apply -f sample-secret.yaml` (create a sample secret that syncs a secret from Vault, ensure the path mentioned in sample-secret.yaml exists in Vault)
16. 
