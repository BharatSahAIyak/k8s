## Setting up Promtail

1. Create promtail-config

`kubectl create configmap promtail-config --from-file=promtail-config.yaml`

2. Apply Promtail

`kubectl apply -f promtail.yaml`