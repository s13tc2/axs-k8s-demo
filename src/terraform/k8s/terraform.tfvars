application_name         = "fleet-app"
environment_name         = "dev"
k8s_namespace            = "app"
k8s_service_account_name = "fleet-portal"
web_app_image = {
  name    = "ecr-fleet-portal-dev-frontend"
  version = "2024.10.4"
}
web_api_image = {
  name    = "ecr-fleet-portal-dev-backend"
  version = "2024.10.15"
}