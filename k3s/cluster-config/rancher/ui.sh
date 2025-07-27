# adding repo
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

# installing rancher
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.k3s.larek.tech \
  --set bootstrapPassword=admin \
  --set ingress.tls.source=secret \
  --set ingress.tls.secretName=tls-rancher-ingress
