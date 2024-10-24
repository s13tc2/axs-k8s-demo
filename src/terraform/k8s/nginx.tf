resource "helm_release" "ingress" {
  name             = "ingress"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "nginx-ingress-controller"
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
  
  # Add WebSocket support
  set {
    name  = "controller.config.proxy-read-timeout"
    value = "3600"
  }
  
  set {
    name  = "controller.config.proxy-send-timeout"
    value = "3600"
  }
  
  set {
    name  = "controller.config.proxy-connect-timeout"
    value = "3600"
  }
  
  set {
    name  = "controller.config.enable-underscores-in-headers"
    value = "true"
  }
  
  set {
    name  = "controller.config.use-forwarded-headers"
    value = "true"
  }
  
  # Specific for Blazor WebSocket
  set {
    name  = "controller.config.proxy-buffer-size"
    value = "128k"
  }
  
  set {
    name  = "controller.config.proxy-buffers-number"
    value = "4"
  }
  
  set {
    name  = "controller.config.keep-alive"
    value = "75"
  }
  
  set {
    name  = "controller.config.upstream-keepalive-timeout"
    value = "60"
  }
  
  set {
    name  = "controller.config.upstream-keepalive-requests"
    value = "100"
  }
  
  # Optional but recommended for better WebSocket performance
  set {
    name  = "controller.config.use-gzip"
    value = "true"
  }

  # Add these new configurations for sticky sessions
  set {
    name  = "controller.config.use-proxy-protocol"
    value = "true"
  }

  set {
    name  = "controller.config.enable-sticky-sessions"
    value = "true"
  }

  set {
    name  = "controller.config.upstream-hash-by"
    value = "$remote_addr"
  }

  # Add SignalR specific configurations
  set {
    name  = "controller.config.map-hash-bucket-size"
    value = "128"
  }

  set {
    name  = "controller.config.worker-connections"
    value = "10240"
  }

  set {
    name  = "controller.config.max-worker-connections"
    value = "10240"
  }

  set {
    name  = "controller.config.worker-processes"
    value = "auto"
  }
}