
output "prometheus_url" {
  description = "URL of Prometheus"
  value       = "http://prometheus-operated.monitoring.svc.cluster.local:9090"
}

output "grafana_url" {
  description = "URL of Grafana"
  value       = kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname
}

output "grafana_admin_password" {
  description = "Initial admin password for Grafana"
  value       = random_password.grafana_admin_password.result
  sensitive   = true
}