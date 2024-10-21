resource "helm_release" "csi_secrets_store" {
  name       = "csi-secrets-store"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"
  version    = "1.3.4"  # Specify the latest stable version

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
}

resource "helm_release" "aws_secrets_provider" {
  name       = "secrets-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"
  version    = "0.3.4"  # Specify the latest stable version

  depends_on = [helm_release.csi_secrets_store]
}

locals {
  secrets = {
    "fleet-portal-dev-connection-string" = "DB_CONNECTION_STRING"
  }
}

resource "time_sleep" "wait_for_crds" {
  depends_on = [
    helm_release.csi_secrets_store,
    helm_release.aws_secrets_provider
  ]
  create_duration = "60s"
}

resource "null_resource" "verify_crd" {
  depends_on = [time_sleep.wait_for_crds]

  provisioner "local-exec" {
    command = "kubectl get crd secretproviderclasses.secrets-store.csi.x-k8s.io"
  }
}

resource "kubernetes_manifest" "secret_provider_class" {
  depends_on = [null_resource.verify_crd]

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
        objects = jsonencode([
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
}
