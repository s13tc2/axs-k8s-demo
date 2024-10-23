resource "helm_release" "ingress" {
  name       = "ingress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  create_namespace = true
  namespace        = "ingress-nginx"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "service.annotations"
    value = "service.beta.kubernetes.io/aws-load-balancer-type: nlb"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "controller.scope.enabled"
    value = "false"
  }
  set {
    name  = "ingressClassResource.enabled"
    value = "true"
  }
  set {
    name  = "ingressClassResource.name"
    value = "nginx"
  }
  set {
    name  = "ingressClass"
    value = "nginx"
  }
  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
}
