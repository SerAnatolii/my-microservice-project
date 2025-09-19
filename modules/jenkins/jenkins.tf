
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.8.90"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "controller.adminUser"
    value = "admin"
  }

  set_sensitive {
    name  = "controller.adminPassword"
    value = random_password.jenkins_admin_password.result
  }

  depends_on = [kubernetes_namespace.jenkins]
}

resource "random_password" "jenkins_admin_password" {
  length  = 16
  special = true
}