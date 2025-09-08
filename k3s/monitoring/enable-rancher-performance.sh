#!/bin/bash

# Enable Rancher Performance Dashboard
# This script enables CATTLE_PROMETHEUS_METRICS for Rancher performance monitoring

set -e

echo "🔧 Enabling Rancher Performance Dashboard..."

# Set KUBECONFIG
export KUBECONFIG=../clusters/kubeconfig.yaml

# Get current Rancher deployment
kubectl patch deployment rancher -n cattle-system --type='merge' -p='
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "rancher", 
            "env": [
              {
                "name": "CATTLE_PROMETHEUS_METRICS",
                "value": "true"
              }
            ]
          }
        ]
      }
    }
  }
}'

echo "✅ Rancher Performance Dashboard enabled!"
echo "📊 You can now access the Rancher Performance Dashboard in Grafana"
echo "   Search for 'Rancher Performance Debugging' dashboard in Grafana"
