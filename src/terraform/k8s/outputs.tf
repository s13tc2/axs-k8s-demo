output "k8s_namespace" {
  value = var.k8s_namespace
}

output "ingress_controller_namespace" {
  value = "${var.k8s_service_account_name}-ingress"
}

output "web_api_image_name" {
  value = var.web_api_image.name
}

output "web_api_image_version" {
  value = var.web_api_image.version
}

output "registry_endpoint" {
  value = data.aws_ecr_repository.web_api_repository.repository_url
}

output "image_version" {
  value = var.web_api_image.version
}

