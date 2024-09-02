variable "namespace_name" {
  description = "The name of the Kubernetes namespace"
  type        = string
}

variable "environment_port" {
  description = "The port to use for this environment"
  type        = number
}

variable "storage_size" {
  description = "The size of the persistent volume claim"
  type        = string
  default     = "1Gi"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "react_app" {
  metadata {
    name = var.namespace_name
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
        storage = var.storage_size
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
    replicas = 1
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
      port        = var.environment_port
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
