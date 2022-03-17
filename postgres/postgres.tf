# vim: syntax=yaml
variable "host_count" {
  default = "2"
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
  uri   = "qemu+ssh://root@192.168.0.4/system"
}

#resource "libvirt_pool" "postgres" {
#  name = "postgres"
#  type = "dir"
#  path = "/virtualki/postgres"
#}

resource "libvirt_network" "postgres" {
  name = "postgres"
  mode = "bridge"
  bridge = "br0"
  autostart = "true"
}

resource "libvirt_volume" "volume" {
  count = "${var.host_count}"
  name = "postgres${count.index + 1}"
  #pool = "postgres"
  pool = "default"
#  source = "http://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
#  source = "http://ftp.linux.cz/pub/linux/almalinux/8.5/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
  source = "http://192.168.0.2:8765/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
  format = "qcow2"
}

data "template_file" "meta_data" {
  count = "${var.host_count}"
  template = file("${path.module}/meta_data.cfg")
  vars = {
    HOSTNAME = "postgres${count.index + 1}"
    FQDN = "postgres${count.index + 1}" 
    ID = "ID-${count.index + 1}"
  }
}

data "template_file" "user_data" {
  template = format("%s%s",file("${path.module}/../user_data_base.cfg"),file("${path.module}/user_data_postgres.cfg"))
}

# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "cloudinit" {
  count = "${var.host_count}"
  name = "cloudinit-postgres${count.index + 1}.iso"
  meta_data  = "${data.template_file.meta_data[count.index].rendered}"
  user_data  = "${data.template_file.user_data.rendered}"
  #pool = "postgres"
  pool = "default"
}

# Define KVM domain to create
resource "libvirt_domain" "virtkubes" {
  count = "${var.host_count}"
  name   = "postgres${count.index + 1}"
  memory = "2048"
  vcpu   = 2

  network_interface {
    network_name = "${libvirt_network.postgres.name}"
    #network_name = "default"
    wait_for_lease = true
    mac = "44:8a:5b:00:03:0${count.index + 1}"
    hostname = "postgres${count.index + 1}"
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
  #count = "${var.host_count}"
  value = "${libvirt_domain.virtkubes.*.network_interface.0.addresses.0}"
}

