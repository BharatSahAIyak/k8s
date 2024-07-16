## Setting up Promtail

1. Create promtail-config (ensure to update the loki url in the file promtail-config.yaml)

`kubectl create configmap promtail-config --from-file=promtail-config.yaml`

2. Apply Promtail

`kubectl apply -f promtail.yaml`