#!/bin/env bash
set -ex
cat <<EOF | kubectl create -f -     
apiVersion: batch/v1
kind: Job
metadata:
  name: test-job-gpu
spec:
  template:
    spec:
      runtimeClassName: nvidia
      containers:
      - name: nvidia-test
        image: nvidia/cuda:12.0.0-base-ubuntu22.04
        command: ["nvidia-smi"]
        resources:
          limits:
            nvidia.com/gpu: 1
      restartPolicy: Never
EOF
kubectl wait --for=condition=complete job/test-job-gpu 
kubectl logs job/test-job-gpu
kubectl delete job/test-job-gpu

