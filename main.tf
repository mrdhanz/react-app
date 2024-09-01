provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "react_app" {
  metadata {
    name = "react-app"
  }
}

resource "kubernetes_persistent_volume_claim" "react_app_pvc" {
  metadata {
    name      = "react-app-pvc"
    namespace = kubernetes_namespace.react_app.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "react_app" {
  metadata {
    name      = "react-app"
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
            container_port = 8085
          }

          volume_mount {
            name       = "react-app-volume"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "react-app-volume"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.react_app_pvc.metadata[0].name
          }
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
      port        = 8085
      target_port = 8085
    }

    type = "LoadBalancer"
  }
}
