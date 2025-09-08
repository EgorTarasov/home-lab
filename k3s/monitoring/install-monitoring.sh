#!/bin/bash

# Rancher Monitoring Installation Script
# This script installs Rancher Monitoring stack on your k3s cluster

set -e

echo "🔍 Installing Rancher Monitoring Stack..."

# Set KUBECONFIG
export KUBECONFIG=../clusters/kubeconfig.yaml

# Add Rancher charts repository
echo "📦 Adding Rancher Helm repository..."
helm repo add rancher-charts https://charts.rancher.io
helm repo update

# Create namespace for monitoring
echo "🏗️  Creating cattle-monitoring-system namespace..."
kubectl create namespace cattle-monitoring-system --dry-run=client -o yaml | kubectl apply -f -

# Install Rancher Monitoring
echo "🚀 Installing Rancher Monitoring..."
helm upgrade --install rancher-monitoring rancher-charts/rancher-monitoring \
  --namespace cattle-monitoring-system \
  --version 103.1.1+up45.31.1 \
  --values /Users/egortarasov/dev/home-lab/terraform/values/monitoring.yaml \
  --timeout 10m0s \
  --wait

# Create Grafana certificate
echo "🔐 Creating SSL certificate for Grafana..."
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: tls-grafana-ingress
  namespace: cattle-monitoring-system
spec:
  secretName: tls-grafana-ingress
  issuerRef:
    name: cloudflare-clusterissuer
    kind: ClusterIssuer
  dnsNames:
    - grafana.k3s.larek.tech
EOF

# Wait for deployment to be ready
echo "⏳ Waiting for monitoring components to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus --timeout=300s -n cattle-monitoring-system
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=300s -n cattle-monitoring-system
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=alertmanager --timeout=300s -n cattle-monitoring-system

echo "✅ Rancher Monitoring installation completed!"
echo ""
echo "📊 Access Points:"
echo "  Grafana:     https://grafana.k3s.larek.tech"
echo "  Prometheus:  https://rancher.k3s.larek.tech/k8s/clusters/c-m-xxxxx:xxxxx/api/v1/namespaces/cattle-monitoring-system/services/http:rancher-monitoring-prometheus:9090/proxy/"
echo "  Alertmanager: https://rancher.k3s.larek.tech/k8s/clusters/c-m-xxxxx:xxxxx/api/v1/namespaces/cattle-monitoring-system/services/http:rancher-monitoring-alertmanager:9093/proxy/"
echo ""
echo "🔑 Default Credentials:"
echo "  Grafana Admin: admin / admin"
echo ""
echo "📝 Check installation status:"
echo "  kubectl get pods -n cattle-monitoring-system"
echo "  kubectl get certificate -n cattle-monitoring-system"
