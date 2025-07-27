#!/bin/bash

# installing k3s on master node
curl -sfL https://get.k3s.io | sh -

# exposing node-token for worker nodes
cat /var/lib/rancher/k3s/server/node-token

# install helm chart support (https://helm.sh/docs/intro/install/)
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# adding rancher repositories
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
# creating namespace for rancher
kubectl create namespace rancher