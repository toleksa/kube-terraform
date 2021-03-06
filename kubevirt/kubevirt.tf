# vim: syntax=yaml
variable "host_count" {
  default = "1"
}

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.12"
    }
  }
}

provider "libvirt" {
  uri   = "qemu+ssh://root@192.168.0.3/system"
}

#resource "libvirt_pool" "kube" {
#  name = "kube"
#  type = "dir"
#  path = "/virtualki/kube"
#}

resource "libvirt_network" "kubevirt" {
  name = "kubevirt"
  mode = "bridge"
  bridge = "br0"
  autostart = "true"
}

resource "libvirt_volume" "volume" {
  count = "${var.host_count}"
  name = "kubevirt${count.index + 1}"
  #pool = "kube"
  pool = "default"
  #source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img" #too small disk, needs resize
  source = "http://192.168.0.2:8765/focal-server-cloudimg-amd64-disk-kvm-50G.img"
  format = "qcow2"
}

data "template_file" "meta_data" {
  count = "${var.host_count}"
  template = file("${path.module}/meta_data.cfg")
  vars = {
    HOSTNAME = "kubevirt${count.index + 1}.kube.ac"
    FQDN = "kubevirt${count.index + 1}.kube.ac" 
    ID = "ID-kubevirt${count.index + 1}"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.cfg")
}

# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "cloudinit" {
  count = "${var.host_count}"
  name = "cloudinit-kubevirt${count.index + 1}.iso"
  meta_data  = "${data.template_file.meta_data[count.index].rendered}"
  user_data  = "${data.template_file.user_data.rendered}"
  #pool = "kube"
  pool = "default"
}

# Define KVM domain to create
resource "libvirt_domain" "kubevirt" {
  count = "${var.host_count}"
  name   = "kubevirt${count.index + 1}"
  memory = "3500"
  vcpu   = 3

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_name = "${libvirt_network.kubevirt.name}"
    #network_name = "default"
    #wait_for_lease = true
    hostname = "kubevirt${count.index + 1}.kube.ac"
  }

  disk {
    volume_id = "${libvirt_volume.volume[count.index].id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.cloudinit[count.index].id}"

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

