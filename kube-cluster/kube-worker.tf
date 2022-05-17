# vim: syntax=yaml
resource "libvirt_volume" "kube-worker" {
  count           = var.worker_count
  name            = "kube-${var.cluster_name}-worker-${count.index}-disk"
  base_volume_id  = libvirt_volume.kube.id
  pool            = libvirt_volume.kube.pool
  format          = "qcow2"
}

resource "libvirt_cloudinit_disk" "worker-init" {
  count          = var.worker_count
  name           = "kube-${var.cluster_name}-worker-${count.index}-init.iso"
  user_data      = data.template_file.worker_user_data[count.index].rendered
  pool           = libvirt_volume.kube.pool
}

data "template_file" "worker_user_data" {
  count = "${var.worker_count}"
  template = format("%s%s",file("${path.module}/../user_data_base.cfg"),file("${path.module}/user_data_kube.cfg"))
  vars = {
    HOSTNAME = "w${count.index}.${var.cluster_name}.${var.cluster_domain}",
    JOIN_ADDR = "s0.${var.cluster_name}.${var.cluster_domain}"
    JOIN_TOKEN = "${var.join_token}"
    PREFIX = ""
    RKE2_TYPE = "agent"
  }
}

# Define KVM domain to create
resource "libvirt_domain" "kube-worker" {
  count = "${var.worker_count}"
  name   = "${var.cluster_name}.w${count.index}"
  memory = "${var.worker_mem}"
  vcpu   = "${var.worker_vcpu}"

  network_interface {
    network_id = "${libvirt_network.kube.id}"
    wait_for_lease = true
    mac = "44:8a:5b:00:03:1${count.index}"
    hostname = "s${count.index}.${var.cluster_name}.${var.cluster_domain}"
  }

  disk {
    volume_id = "${libvirt_volume.kube-worker[count.index].id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.worker-init[count.index].id}"

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

output "ip-workers" {
  value = {
    for host in libvirt_domain.kube-worker:
    host.name => host.network_interface.0.addresses.*
  }
}
