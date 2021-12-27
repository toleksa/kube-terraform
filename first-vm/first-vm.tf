# vim: syntax=yaml
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

resource "libvirt_pool" "first-vm" {
  name = "first-vm"
  type = "dir"
  path = "/virtualki/first-vm"
}

resource "libvirt_network" "br0" {
  name = "br0"
  mode = "bridge"
  bridge = "br0"
  autostart = "true"
}

resource "libvirt_volume" "first-ubuntu-20_04" {
  name = "first-ubuntu-20_04"
  pool = "${libvirt_pool.first-vm.name}"
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  #source = "/virtualki/templates/CentOS-7-x86_64-GenericCloud.qcow2"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.cfg")}"
}


# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  user_data      = "${data.template_file.user_data.rendered}"
  pool = "${libvirt_pool.first-vm.name}"
}

# Define KVM domain to create
resource "libvirt_domain" "first" {
  name   = "first"
  memory = "1024"
  vcpu   = 1

  network_interface {
    network_name = "${libvirt_network.br0.name}"
    #network_name = "default"
    hostname = "first"
    #wait_for_lease = true
  }

  disk {
    volume_id = "${libvirt_volume.first-ubuntu-20_04.id}"
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
#  value = "${libvirt_domain.first.network_interface.0.addresses.0}"
#}

