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

#resource "libvirt_pool" "kube" {
#  name = "kube-cluster"
#  type = "dir"
#  path = "/virtualki/kube-cluster"
#}

resource "libvirt_network" "kube" {
  count = (var.network_bridge != "default" ? 1 : 0)
  name = "kube-${var.cluster_name}"
  mode = "bridge"
  bridge = "${var.network_bridge}"
  autostart = "true"
}

resource "libvirt_volume" "kube" {
  name = "kube-${var.cluster_name}-base"
  #pool = libvirt_pool.kube.name
  pool = "default"
  source = "${var.os_image}"
  format = "qcow2"
}

terraform {
  backend "local" {}
}

