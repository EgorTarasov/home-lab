// cert-manager installation and Cloudflare DNS-01 ACME configuration

variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone.DNS:Edit for k3s.larek.tech"
  type        = string
  sensitive   = true
}

variable "letsencrypt_email" {
  description = "Email used for Let's Encrypt ACME registration"
  type        = string
}

# Install cert-manager via Helm with CRDs
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.15.3"
  namespace        = "cert-manager"
  create_namespace = true

  # Use values to enable CRD installation
  values = [yamlencode({
    installCRDs = true
  })]
}

# Cloudflare API token Secret for DNS-01 solver
resource "kubernetes_secret_v1" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = "cert-manager"
  }
  type = "Opaque"

  # Base64-encode token for Secret data
  data = {
    api-token = base64encode(var.cloudflare_api_token)
  }

  lifecycle {
    ignore_changes = [data]
  }

  depends_on = [helm_release.cert_manager]
}

# ClusterIssuer configured to use Cloudflare DNS-01 for k3s.larek.tech
// ClusterIssuer is already managed outside of Terraform (k3s/cluster-config).
// Ensure a ClusterIssuer named "cloudflare-clusterissuer" exists in the cluster.

# Ensure namespaces exist for certs we create
resource "kubernetes_namespace_v1" "dev" {
  metadata {
    name = "dev"
  }
}

# Certificate for Rancher (namespace cattle-system)
// Rancher certificate is managed outside Terraform (existing Certificate: cattle-system/rancher-tls)

# Certificate for Dev environment (namespace dev)
resource "kubernetes_manifest" "dev_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "tls-dev-ingress"
      namespace = "dev"
    }
    spec = {
      secretName = "tls-dev-ingress"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      commonName = "dev.k3s.larek.tech"
      dnsNames   = ["dev.k3s.larek.tech"]
    }
  }

  depends_on = [
    helm_release.cert_manager,
    kubernetes_namespace_v1.dev
  ]
}
