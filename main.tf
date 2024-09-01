provider "kubernetes" {
  config_path = "~/.kube/config"  # Ensure this points to your local kubeconfig
}

resource "kubernetes_deployment" "react_app" {
  metadata {
    name = "react-app"
    namespace = "default"
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
          image = "mrdhanz/react-app:latest"
          name  = "react-app"

          ports {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "react_app_service" {
  metadata {
    name = "react-app-service"
  }

  spec {
    selector = {
      app = "react-app"
    }

    port {
      port        = 80
      target_port = 8091
    }

    type = "LoadBalancer"
  }
}
