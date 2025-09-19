
resource "kubernetes_namespace" "argo_cd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.5.0"
  namespace  = kubernetes_namespace.argo_cd.metadata[0].name

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.argo_cd]
}

resource "helm_release" "argo_applications" {
  name       = "argo-applications"
  chart      = "./charts"
  namespace  = kubernetes_namespace.argo_cd.metadata[0].name

  set {
    name  = "applications.django-app.source.repoURL"
    value = "https://github.com/your-repo/django-helm-chart.git"  # Replace with your Helm chart repo URL
  }

  set {
    name  = "applications.django-app.source.path"
    value = "charts/django-app"
  }

  depends_on = [helm_release.argo_cd]
}