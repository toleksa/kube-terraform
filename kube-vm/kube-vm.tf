# vim: syntax=yaml
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}

provider "libvirt" {
  uri   = "qemu+ssh://root@192.168.0.3/system"
}

resource "libvirt_pool" "kube" {
  name = "kube"
  type = "dir"
  path = "/virtualki/kube"
}

resource "libvirt_network" "kube" {
  name = "kube"
  mode = "bridge"
  bridge = "br0"
  autostart = "true"
}

resource "libvirt_volume" "virtkube1" {
  name = "virtkube1"
  pool = "kube"
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  #source = "/virtualki/templates/CentOS-7-x86_64-GenericCloud.qcow2"
  #source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img"
  source = "http://192.168.0.3/focal-server-cloudimg-amd64-disk-kvm.img"
  format = "qcow2"
}

data "template_file" "meta_data" {
  template = "${file("${path.module}/meta_data.cfg")}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.cfg")}"
}


# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  meta_data  = "${data.template_file.meta_data.rendered}"
  user_data  = "${data.template_file.user_data.rendered}"
  pool = "kube"
}

# Define KVM domain to create
resource "libvirt_domain" "virtkube1" {
  name   = "virtkube1"
  memory = "4096"
  vcpu   = 2

  network_interface {
    network_name = "${libvirt_network.kube.name}"
#    network_name = "default"
    hostname = "virtkube1"
#    wait_for_lease = true
  }

  disk {
    volume_id = "${libvirt_volume.virtkube1.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

#output "ip" {
#  value = "${libvirt_domain.virtkube1.network_interface.0.addresses.0}"
#}

