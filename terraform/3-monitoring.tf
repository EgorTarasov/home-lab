resource "kubernetes_namespace" "cattle_monitoring_system" {
  metadata {
    name = "cattle-monitoring-system"
  }
}

# Rancher Monitoring Helm Chart
resource "helm_release" "rancher_monitoring" {
  name       = "rancher-monitoring"
  repository = "https://charts.rancher.io"
  chart      = "rancher-monitoring"
  namespace  = kubernetes_namespace.cattle_monitoring_system.metadata[0].name
  version    = "103.1.1+up45.31.1" # Latest stable version

  # Wait for namespace to be ready
  depends_on = [kubernetes_namespace.cattle_monitoring_system]

  # Use values file for configuration
  values = [
    file("${path.module}/values/monitoring.yaml")
  ]

  # Skip CRDs since we installed them manually
  skip_crds = true

  # Timeout for installation
  timeout = 600
}

# Certificate for Grafana (using your existing cert-manager)
resource "kubernetes_manifest" "grafana_certificate" {
  depends_on = [helm_release.rancher_monitoring]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "tls-grafana-ingress"
      namespace = "cattle-monitoring-system"
    }
    spec = {
      secretName = "tls-grafana-ingress"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = ["grafana.k3s.larek.tech"]
    }
  }
}
