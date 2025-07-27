# Home-lab

This repository represents my home-lab setup, which can be recreated using provided configurations and scripts.
It includes various services and applications that I run at home, such as:
- **k3s**: Lightweight Kubernetes cluster for container orchestration
- **cert-manager**: Automated SSL certificate management with Let's Encrypt and Cloudflare DNS
- **Rancher**: Kubernetes management UI
- **Cloudflare**: DNS management and SSL certificate validation
- **Pi-hole**: DNS resolver for local network (planned)
- **WireGuard**: VPN server for secure remote access (planned)
- **Monitoring stack**: Prometheus and Grafana (planned)

## Current Setup
The setup currently consists of:
- **home-lab-node-1** (192.168.1.51): K3s master/control-plane node
  - Role: control-plane, master
  - CPU: 16 cores
  - Network: Flannel CNI with VXLAN backend
  - Services: K3s server, cert-manager, Rancher

## Services & Components

### 🔐 SSL Certificate Management
- **cert-manager**: Automated SSL certificates using Let's Encrypt
- **DNS-01 Challenge**: Using Cloudflare API for domain validation
- **Domain**: `*.k3s.larek.tech` with wildcard certificates
- **ClusterIssuer**: `cloudflare-clusterissuer` for automatic certificate provisioning

### 🎛️ Cluster Management
- **Rancher UI**: Web-based Kubernetes management interface
  - URL: `https://rancher.k3s.larek.tech`
  - SSL: Automated certificate from cert-manager
  - Bootstrap password: admin

### 🌐 Networking
- **Internal Network**: 192.168.1.0/24
- **Pod CIDR**: 10.42.0.0/24
- **External Domain**: `larek.tech` managed by Cloudflare
- **K3s Subdomain**: `*.k3s.larek.tech` for cluster services

## Security & Secrets Management

### What's Safe to Commit:
- ✅ Local IP addresses (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
- ✅ Internal DNS names and network topology
- ✅ Configuration templates (.env.example files)
- ✅ Port numbers for internal services

### What Should NEVER be Committed:
- ❌ API tokens and keys (Cloudflare, GitHub, etc.)
- ❌ Public IP addresses
- ❌ Passwords and authentication credentials
- ❌ SSL certificates and private keys
- ❌ MAC addresses (can be used for tracking)

### Secret Management:
- Use `.env.example` files as templates
- Store real secrets in GitHub Secrets for CI/CD
- Use Kubernetes Secrets for runtime configuration
- Consider External Secrets Operator for production


## Repository Structure
```
├── clusters/
│   ├── kubeconfig.yaml         # K3s cluster configuration (gitignored)
│   └── .gitignore
├── k3s/
│   ├── cluster-config/
│   │   ├── cert-manager/
│   │   │   ├── clusterissuer.yaml        # Cloudflare ClusterIssuer for Let's Encrypt
│   │   │   └── secret-cloudflare.yaml    # Cloudflare API token secret
│   │   └── rancher/
│   │       ├── certificate.yaml          # SSL certificate for Rancher UI
│   │       └── ui.sh                     # Rancher installation script
│   ├── ingress/                          # Ingress configurations (planned)
│   └── monitoring/                       # Monitoring stack (planned)
├── configs/
│   ├── network.md                        # Network configuration documentation
│   ├── pi-hole/                          # Pi-hole configurations (planned)
│   └── wireguard/                        # WireGuard VPN configurations (planned)
├── scripts/
│   ├── master.sh                         # K3s master node setup script
│   └── worker.sh                         # K3s worker node setup script
└── readme.md
```

## Quick Start

### 1. K3s Cluster Setup
```bash
# On master node
./scripts/master.sh

# On worker nodes (set environment variables first)
export K3S_URL="https://192.168.1.51:6443"
export K3S_TOKEN="<node-token-from-master>"
./scripts/worker.sh
```

### 2. Cert-manager Installation
```bash
# Add Jetstack repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.18.2 \
  --set crds.enabled=true

# Apply Cloudflare secret (update with your API token)
kubectl apply -f k3s/cluster-config/cert-manager/secret-cloudflare.yaml

# Apply ClusterIssuer
kubectl apply -f k3s/cluster-config/cert-manager/clusterissuer.yaml
```

### 3. Rancher UI Installation
```bash
# Create namespace
kubectl create namespace cattle-system

# Apply SSL certificate
kubectl apply -f k3s/cluster-config/rancher/certificate.yaml

# Install Rancher
chmod +x k3s/cluster-config/rancher/ui.sh
./k3s/cluster-config/rancher/ui.sh
```

## DNS Configuration
Configure the following DNS records in Cloudflare:
```
Type: A
Name: *.k3s.larek.tech
Content: <your-external-ip>
Proxy: DNS only
```

## Progress Tracking
### ✅ Completed
- [x] K3s cluster setup with single master node
- [x] Helm package manager installation
- [x] cert-manager installation and configuration
- [x] Cloudflare DNS-01 challenge integration
- [x] SSL certificate automation for `*.k3s.larek.tech`
- [x] Rancher UI deployment with SSL certificates

### 🚧 In Progress
- [ ] Worker node integration
- [ ] Ingress controller configuration
- [ ] Service mesh setup

### 📋 Planned
- [ ] Network Infrastructure
  - [ ] Add each MAC address to DHCP server
  - [ ] Setup static IP for additional nodes
  - [ ] Setup Pi-hole for DNS resolution
  - [ ] Setup WireGuard VPN server
- [ ] Monitoring and Observability
  - [ ] Setup Prometheus for metrics collection
  - [ ] Setup Grafana for visualization
  - [ ] Setup AlertManager for notifications
- [ ] GitOps and Automation
  - [ ] Setup FluxCD for GitOps deployment
  - [ ] Setup GitHub Actions runners
  - [ ] Infrastructure as Code with Ansible
- [ ] Additional Services
  - [ ] Application deployment pipelines
  - [ ] Backup and disaster recovery
  - [ ] Network policies and security hardening

## Troubleshooting

### Common Issues
1. **Certificate not issuing**: Check DNS propagation with `dig TXT _acme-challenge.rancher.k3s.larek.tech`
2. **Rancher UI not accessible**: Verify certificate status with `kubectl get certificate -n cattle-system`
3. **DNS resolution issues**: Ensure `*.k3s.larek.tech` points to your external IP

### Useful Commands
```bash
# Check cluster status
kubectl get nodes -o wide

# Check cert-manager status
kubectl get clusterissuer
kubectl get certificate -A

# Check Rancher deployment
kubectl get pods -n cattle-system

# View cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager -f
```