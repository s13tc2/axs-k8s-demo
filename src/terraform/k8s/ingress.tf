resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "${local.web_app_name}-ingress"
    namespace = var.k8s_namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      
      # WebSocket specific annotations
      "nginx.ingress.kubernetes.io/proxy-read-timeout"  = "3600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"  = "3600"
      "nginx.ingress.kubernetes.io/proxy-connect-timeout" = "3600"
      "nginx.ingress.kubernetes.io/websocket-services"  = kubernetes_service.web_app.metadata[0].name
      
      # Sticky sessions for SignalR
      "nginx.ingress.kubernetes.io/affinity"            = "cookie"
      "nginx.ingress.kubernetes.io/session-cookie-name" = "sticky-session"
      "nginx.ingress.kubernetes.io/session-cookie-expires" = "172800"
      "nginx.ingress.kubernetes.io/session-cookie-max-age" = "172800"
      
      # Blazor/SignalR specific configuration
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOF
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Connection keep-alive;
        
        # SignalR specific headers
        proxy_set_header X-SignalR-User-Agent $http_user_agent;
        proxy_pass_request_headers on;
        
        # Additional WebSocket stability
        proxy_buffering off;
        proxy_request_buffering off;
      EOF

      # Additional stability settings
      "nginx.ingress.kubernetes.io/proxy-buffer-size" = "128k"
      "nginx.ingress.kubernetes.io/client-max-body-size" = "50m"
      "nginx.ingress.kubernetes.io/proxy-buffers-number" = "4"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.web_app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
        path {
          path      = "/api"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.web_api.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.web_app,
    kubernetes_service.web_api,
    helm_release.ingress
  ]
}