# ArgoCD Helm installation
resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "8.3.0"

  values = [file("values/argocd.yaml")]
}


# ArgoCD SSL Certificate
resource "kubernetes_manifest" "argocd_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "tls-argocd-ingress"
      namespace = "argocd"
    }
    spec = {
      secretName = "tls-argocd-ingress"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      commonName = "argocd.k3s.larek.tech"
      dnsNames = [
        "argocd.k3s.larek.tech"
      ]
    }
  }

  depends_on = [helm_release.argocd]
}


# ArgoCD Ingress
resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argocd-server-ingress"
    namespace = "argocd"
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"         = "true"
      "traefik.ingress.kubernetes.io/backend.protocol"   = "grpc"
      # Add this to handle gRPC-Web properly
      "traefik.ingress.kubernetes.io/grpc-web" = "true"
    }
  }

  spec {
    ingress_class_name = "traefik"
    tls {
      hosts       = ["argocd.k3s.larek.tech"]
      secret_name = "tls-argocd-ingress"
    }

    rule {
      host = "argocd.k3s.larek.tech"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_manifest.argocd_certificate
  ]
}
