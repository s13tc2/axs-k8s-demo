output "k8s_namespace" {
  value = var.k8s_namespace
}

output "ingress_controller_namespace" {
  value = "${var.k8s_service_account_name}-ingress"
}