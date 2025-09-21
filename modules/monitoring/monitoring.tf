
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "62.5.0"  # Використовуйте актуальну версію
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "grafana.adminPassword"
    value = random_password.grafana_admin_password.result
  }

  depends_on = [kubernetes_namespace.monitoring]
}

resource "random_password" "grafana_admin_password" {
  length  = 16
  special = true
}

# ServiceMonitor для Django-застосунку
resource "kubernetes_manifest" "django_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "django-app-monitor"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        "release" = "prometheus"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "django-app"
        }
      }
      endpoints = [
        {
          port = "http"
          path = "/metrics"
        }
      ]
    }
  }

  depends_on = [helm_release.kube_prometheus_stack]
}