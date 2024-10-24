resource "helm_release" "ingress" {
  name       = "ingress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  create_namespace = true
  namespace        = "ingress-nginx"

  # Override the fullname to ensure consistent naming
  set {
    name  = "fullnameOverride"
    value = "ingress-nginx-controller"
  }

  # Set the service type to LoadBalancer
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  # Set service annotations for AWS NLB, with additional options
  set {
    name  = "service.annotations"
    value = "service.beta.kubernetes.io/aws-load-balancer-type: nlb, service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval: '20', service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: 'true'"
  }

  # Enable RBAC creation
  set {
    name  = "rbac.create"
    value = "true"
  }

  # Ensure the controller watches all namespaces
  set {
    name  = "controller.scope.enabled"
    value = "false"
  }

  # Create and specify the ServiceAccount, using the consistent name
  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }
  set {
    name  = "controller.serviceAccount.name"
    value = "ingress-nginx-controller"  # Updated to match other references
  }

  # Enable and configure the IngressClass resource
  set {
    name  = "ingressClassResource.enabled"
    value = "true"
  }
  set {
    name  = "ingressClassResource.name"
    value = "nginx"
  }
  set {
    name  = "ingressClassResource.controllerValue"
    value = "k8s.io/ingress-nginx"
  }
  set {
    name  = "ingressClass"
    value = "nginx"
  }
}
