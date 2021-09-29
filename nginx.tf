terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}
provider "kubernetes" {
  config_path = "/etc/rancher/rke2/rke2.yaml"
}
resource "kubernetes_namespace" "test" {
  metadata {
    name = "nginx"
  }
}
resource "kubernetes_deployment" "test" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "MyTestApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyTestApp"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "test" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.test.spec.0.template.0.metadata.0.labels.app
    }
    #type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}
resource "kubernetes_ingress" "test" {
  wait_for_load_balancer = true
  metadata {
    name = "nginx-ingress"
    namespace = kubernetes_namespace.test.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      host = "nginx.kube.ac"
      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.test.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}
