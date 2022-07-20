# vim: syntax=yaml
{% for provider in iac.providers|default([]) %}
provider "{{ provider['name'] }}" {
    uri = "{{ provider['config'] }}"
}
{% endfor %}

terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "{{ libvirt.config.source }}"
      version = "{{ libvirt.config.version }}"
    }
  }
}

terraform {
  backend "local" {}
}

{% for pool in iac.pools|default([]) %}
{%   if pool['name']!="default" %}

resource "libvirt_pool" "{{iac.name}}-{{ pool['name'] }}" {
  name = "{{iac.name}}-{{ pool['name'] }}"
  type = "dir"
  path = "{{ pool['path'] }}"
}
{%   endif %}
{% endfor %}

{% for network in iac.networks|default([]) %}
{%   if network['name']!="default" %}

resource "libvirt_network" "{{iac.name}}-{{ network['name'] }}" {
  name = "{{iac.name}}-{{network['name'] }}"
  mode = "bridge"
  bridge = "{{ network['bridge'] }}"
  autostart = "true"
}
{%   endif %}
{% endfor %}

{% for volume in iac.volumes|default([]) %}

resource "libvirt_volume" "{{iac.name}}-{{ volume['name'] }}" {
  name = "{{iac.name}}-{{ volume['name'] }}"
  source = "{{ volume['source'] }}"
  format = "{{ volume['format'] }}"
{%   if volume['pool']=="default" %}
  pool = "default"
{%   else %}
  pool = "{{iac.name}}-{{ volume['pool'] }}"
{%   endif %}
}

{% endfor %}

{% for count in range(instance.value.count) %}
{%   for disk in instance.value.disks|default([]) %}
resource "libvirt_volume" "{{iac.name}}-{{instance.key}}{{count}}-{{disk.name}}" {
  name = "{{iac.name}}-{{instance.key}}{{count}}-{{disk.name}}"
{%     if disk.pool=="default" %}
  pool = "default"
{%     else %}
  pool = "{{iac.name}}-{{disk.pool}}"
{%     endif %}
{%     if disk.base_volume|default(False) %}
  base_volume_id = libvirt_volume.{{iac.name}}-{{disk.base_volume}}.id
{%     elif disk.source|default(False) %}
  source = "{{disk.source}}"
{%     endif %}
{%     if disk.size | default(False) %}
  size = "{{ disk.size|human_to_bytes }}"
{%     endif %}
}
{%   endfor %}

{%   if instance.value.user_data|default(False) %}
resource "libvirt_cloudinit_disk" "{{iac.name}}-{{instance.key}}{{count}}-cloudinit" {
  name           = "{{iac.name}}-{{instance.key}}{{count}}-cloudinit.iso"
  pool = "{{ instance.value.user_data_pool|default(instance.value.disks[0].pool) }}"
  user_data      = <<EOF
#cloud-config
fqdn: "{{instance.key}}{{count}}.{{iac.name}}.{{iac.domain}}"
{{instance.value.user_data|default('')|to_nice_yaml(indent=2)}}
EOF
}
{%   endif %}

# Define KVM domain to create
resource "libvirt_domain" "{{iac.name}}-{{instance.key}}{{count}}" {
  name   = "{{iac.name}}-{{instance.key}}{{count}}"
  description = "cluster: {{iac.name}}\nhostname: {{instance.key}}{{count}}"
  memory = "{{ instance.value.resources.mem|default(1024) }}"
  vcpu   = "{{ instance.value.resources.cpu|default(1) }}"

  cpu {
      mode = "host-passthrough" 
  }

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

{%   if instance.value.user_data|default(False) %}
  cloudinit = libvirt_cloudinit_disk.{{iac.name}}-{{instance.key}}{{count}}-cloudinit.id
{%   endif %}

{%   for disk in instance.value.disks|default([]) %}
  disk {
    volume_id = libvirt_volume.{{iac.name}}-{{instance.key}}{{count}}-{{disk.name}}.id
    scsi      = "true"
    wwn       = "{{ '%016d' % loop.index0 }}"
  }
{%   endfor %}


{%   for network in instance.value.networks|default([]) %}
  network_interface {
{%     if network.name|default(false) %}
    network_name = "{{iac.name}}-{{network.name}}"
{%     endif %}
{%     if network.mac_prefix|default(false) %}
{%       if instance.value.count < 10 %}
    mac            = "{{network.mac_prefix}}:0{{count}}"
{%       elif instance.value.count < 100 %}
    mac            = "{{network.mac_prefix}}:{{ '%02d' % count}}"
{%       endif %}
{%     endif %}
    wait_for_lease = true
  }
{%   endfor %}



}

{% endfor %}

#output "ip-servers" {
#  value = {
#    for host in libvirt_domain.*:
#    host.name => host.network_interface.0.addresses.*
#  }
#}





