resource "helm_release" "csi_secrets_store" {
  name       = "csi-secrets-store"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }

  wait    = true
  timeout = 300  # Wait up to 300 seconds
}

resource "helm_release" "aws_secrets_provider" {
  name       = "secrets-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"

  depends_on = [helm_release.csi_secrets_store]

  wait    = true
  timeout = 300  # Wait up to 300 seconds
}

locals {
  secrets = {
    "fleet-portal-dev-connection-string" = "DB_CONNECTION_STRING"
  }
}

resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "${var.application_name}-${var.environment_name}-secret-provider-class"
      namespace = var.k8s_namespace
    }
    spec = {
      provider = "aws"
      parameters = {
        objects = yamlencode([
          {
            objectName         = "fleet-portal-dev-connection-string"
            objectType         = "secretsmanager"
            objectVersionLabel = "AWSCURRENT"
          }
        ])
      }
      secretObjects = [
        {
          data = [
            {
              key        = "fleet-portal-dev-connection-string"
              objectName = "fleet-portal-dev-connection-string"
            }
          ]
          secretName = "fleet-portal-dev-connection-string"
          type       = "Opaque"
        }
      ]
    }
  }

  depends_on = [
    helm_release.aws_secrets_provider
  ]
}
