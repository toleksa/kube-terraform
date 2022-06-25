# vim: syntax=yaml
terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.12"
    }
  }
}

provider "libvirt" {
  uri   = var.libvirt_host
}

resource "libvirt_pool" "kube" {
  count = (var.pool_name == "default" ? 0 : 1)
  name = "kube-cluster"
  type = "dir"
  path = "${var.pool_path}"
}

resource "libvirt_network" "kube" {
  count = (var.network_bridge == "default" ? 0 : 1)
  name = "kube-${var.cluster_name}"
  mode = "bridge"
  bridge = "${var.network_bridge}"
  autostart = "true"
}

resource "libvirt_volume" "kube" {
  name = "kube-${var.cluster_name}-base"
  pool = (var.pool_name == "default" ? "default" : libvirt_pool.kube.0.name)
  source = "${var.os_image}"
  format = "qcow2"
}

terraform {
  backend "local" {}
}

