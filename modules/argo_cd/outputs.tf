
output "argo_cd_url" {
  description = "URL of Argo CD"
  value       = "https://${kubernetes_service.argo_cd_server.status[0].load_balancer[0].ingress[0].hostname}"
}

output "argo_cd_admin_password" {
  description = "Initial admin password for Argo CD"
  value       = "initial-password"  # Retrieve from Argo CD secret
  sensitive   = true
}