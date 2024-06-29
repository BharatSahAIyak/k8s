#!/bin/env bash

# usage: ssh -i ~/.ssh/worker_gpu.pem  192.168.0.231 'bash -s' <  install_driver.sh 
set -ex

sudo apt -qq update 
sudo apt -qq install -y  nvidia-driver-550 

echo "Installing NVIDIA container toolkit"
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg 
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get -qq update
sudo apt-get -qq install -y nvidia-container-toolkit


# any package with nvidia in the name should be held
dpkg-query -W --showformat='${Package} ${Status}\n' | \
grep -v deinstall | \
awk '{ print $1 }' | \
grep -E 'nvidia.*-[0-9]+$' | \
xargs -r -L 1 sudo apt-mark hold

echo "configuring containerd"
sudo nvidia-ctk runtime configure --runtime=containerd
sudo systemctl restart containerd
sudo reboot 
