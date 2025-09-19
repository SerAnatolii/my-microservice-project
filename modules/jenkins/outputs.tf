
output "jenkins_url" {
  description = "URL of Jenkins"
  value       = "http://${helm_release.jenkins.name}.${helm_release.jenkins.namespace}.svc.cluster.local:8080"
}

output "jenkins_admin_password" {
  description = "Initial admin password for Jenkins"
  value       = random_password.jenkins_admin_password.result
  sensitive   = true
}