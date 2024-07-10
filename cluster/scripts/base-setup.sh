#! /bin/bash
set -ex
sudo apt-get -qq  update
sudo NEEDRESTART_MODE=a apt-get -qq install -y python3-pip
export PATH="$PATH:/home/ubuntu/.local/bin"
chmod 700 /home/ubuntu/.ssh/*.pem

if ! command -v kubectl &> /dev/null; then
#install kubectl
curl -LO "https://dl.k8s.io/release/v1.29.5/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
fi
