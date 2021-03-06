# vim: syntax=yaml
resource "libvirt_volume" "kube-server" {
  count           = var.server_count
  name            = "kube-${var.cluster_name}-s${count.index}-disk"
  base_volume_id  = libvirt_volume.kube.id
  pool            = libvirt_volume.kube.pool
  format          = "qcow2"
  size            = "53687091200"
}

resource "libvirt_cloudinit_disk" "server-init" {
  count          = var.server_count
  name           = "kube-${var.cluster_name}-s${count.index}-init"
  user_data      = data.template_file.server_user_data[count.index].rendered
  pool           = libvirt_volume.kube.pool
}

data "template_file" "server_user_data" {
  count = "${var.server_count}"
  template = format("%s%s",file("${path.module}/../user_data_base.cfg"),file("${path.module}/user_data_kube.cfg"))
  vars = {
    HOSTNAME = "s${count.index}.${var.cluster_name}.${var.cluster_domain}",
    JOIN_ADDR = "s0.${var.cluster_name}.${var.cluster_domain}"
    JOIN_TOKEN = "${var.join_token}"
    PREFIX = count.index == 0 ? "#" : ""
    RKE2_TYPE = "server"
    ARGO_DOMAIN = "${var.cluster_name}.${var.cluster_domain}"
    ARGO_IP = "${var.cluster_ip}"
  }
}

# Define KVM domain to create
resource "libvirt_domain" "kube-server" {
  count = "${var.server_count}"
  name   = "s${count.index}.${var.cluster_name}"
  memory = "${var.server_mem}"
  vcpu   = "${var.server_vcpu}"

  network_interface {
    #network_id = "${libvirt_network.kube.id}"
    network_name = (var.network_bridge == "default" ? "default" : libvirt_network.kube.0.name)
    wait_for_lease = true
    mac = "${var.mac_prefix}:0${count.index}"
    hostname = "s${count.index}.${var.cluster_name}.${var.cluster_domain}"
  }

  disk {
    volume_id = "${libvirt_volume.kube-server[count.index].id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.server-init[count.index].id}"

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

  description = "cluster: ${var.cluster_name}\nroles: server"
}

output "ip-servers" {
  value = {
    for host in libvirt_domain.kube-server:
    host.name => host.network_interface.0.addresses.*
  }
}

