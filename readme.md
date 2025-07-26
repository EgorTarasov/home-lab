# Home-lab

This repository represents my home-lab setup, which can we recreated using provided configurations and scripts.
It includes various services and applications that I run at home, such as:
- **Pi-hole**: dns resolver for local network
- **Cloudflare** for DNS records
- **WireGuard**: VPN server for secure remote access
- **k3s**: for managing multiple nodes cluster
- **prometheus**: for monitoring and alerting
- **Grafana**: for visualizing metrics and logs

## Setup
Currently setup consists of four nodes:
- **Node 1**: Server running existing coolify services
- **Node 2**: server running pi hole
- **Node 3**: master node for k3s cluster
- **Node 4**: worker node for k3s cluster
- **Node 5**: worker node for k3s cluster with gpu

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

## Repository structure
```
├── k3s/
│   ├── cluster-config/
│   ├── ingress/
│   └── monitoring/
├── ansible/                 # Node configuration
├── configs/
│   ├── .env.example        # Template files
│   ├── wireguard/
│   └── pihole/
└── scripts/                # Setup scripts
```

## Roadmap
- [ ] Setup network for all nodes
    - [ ] add each mac address to dhcp server
    - [ ] setup static ip for each node
    - [ ] setup Pi-hole for DNS resolution
    - [ ] setup WireGuard VPN server
- [ ] Setup k3s cluster
    - [ ] install k3s on master node
    - [ ] join worker nodes to the cluster
    - [ ] setup traefik ingress controller
    - [ ] setup github actions runner
    - [ ] setup ssl certificates for local network using cert-manager and dns-01 challenge
    - [ ] Setup monitoring and alerting
        - [ ] Setup prometheus and grafana
- [ ] Infrastructure as code
    - [ ] Setup ansible for configuration management
    - [ ] Setup argocd for GitOps deployment of applications