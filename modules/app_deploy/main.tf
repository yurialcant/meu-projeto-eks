resource "kubernetes_deployment" "main" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          image = var.app_image_uri
          name  = var.app_name
          port {
            container_port = var.container_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "main" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
  }
  spec {
    selector = {
      app = kubernetes_deployment.main.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = var.container_port
    }
    type = "LoadBalancer" 
  }
}