#!/bin/bash

if [[ -z "$K3S_URL" || -z "$K3S_TOKEN" ]]; then
    echo "Error: K3S_URL and K3S_TOKEN environment variables must be set."
    exit 1
fi

curl -sfL https://get.k3s.io | sh -
echo "connected to master node"