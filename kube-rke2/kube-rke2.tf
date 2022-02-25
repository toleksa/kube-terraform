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

resource "libvirt_network" "kube" {
  name = "kube-r"
  mode = "bridge"
  bridge = "br0"
  autostart = "true"
}

resource "libvirt_volume" "volume" {
  count = "${var.host_count}"
  name = "r${count.index + 1}"
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
    HOSTNAME = "r${count.index + 1}.kube.ac"
    FQDN = "r${count.index + 1}.kube.ac" 
    ID = "ID-r${count.index + 1}"
  }
}

data "template_file" "user_data" {
  template = format("%s%s",file("${path.module}/../user_data_base.cfg"),file("${path.module}/user_data_rke2.cfg"))
}

# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "cloudinit" {
  count = "${var.host_count}"
  name = "cloudinit-r${count.index + 1}.iso"
  meta_data  = "${data.template_file.meta_data[count.index].rendered}"
  user_data  = "${data.template_file.user_data.rendered}"
  #pool = "kube"
  pool = "default"
}

# Define KVM domain to create
resource "libvirt_domain" "virtkubes" {
  count = "${var.host_count}"
  name   = "r${count.index + 1}"
  memory = "4000"
  vcpu   = 4

  network_interface {
    network_name = "${libvirt_network.kube.name}"
    #network_name = "default"
    wait_for_lease = true
    mac = "44:8a:5b:00:01:0${count.index + 1}"
    hostname = "r${count.index + 1}.kube.ac"
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
  qemu_agent = true
}

output "ip" {
  value = "${libvirt_domain.virtkubes[0].network_interface.0.addresses.0}"
}

