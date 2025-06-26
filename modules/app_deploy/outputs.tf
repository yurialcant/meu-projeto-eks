output "application_url" {
  description = "The external URL of the application Load Balancer."
  value       = "http://${kubernetes_service.main.status[0].load_balancer[0].ingress[0].hostname}"
}