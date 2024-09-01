provider "kubernetes" {
  config_path = var.kubeconfig
}
variable "kubeconfig" {
  type = string
}
resource "kubernetes_namespace" "react_app" {
  metadata {
    name = "react-app"
  }
}

resource "kubernetes_deployment" "react_app" {
  metadata {
    name = "react-app"
    namespace = kubernetes_namespace.react_app.metadata[0].name
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "react-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "react-app"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "react-app"

          port {
            container_port = 80
          }

          volume_mount {
            name       = "react-app-volume"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "react-app-volume"

          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "react_app" {
  metadata {
    name      = "react-app"
    namespace = kubernetes_namespace.react_app.metadata[0].name
  }

  spec {
    selector = {
      app = "react-app"
    }

    port {
      port        = 80
      target_port = 8083
    }

    type = "LoadBalancer"
  }
}
