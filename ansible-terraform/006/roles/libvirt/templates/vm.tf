# vim: syntax=yaml
{% for count in range(instance.value.count|default(default.instance.count)) %}
{%   for disk in instance.value.disks|default(default.instance.disks) %}
resource "libvirt_volume" "{{iac.name}}-{{instance.key}}{{count}}-{{disk.name}}" {
  #TODO: hardcoded libvirt
  provider = libvirt.{{instance.value.provider.name|default(iac.providers[0].name)}}
  name = "{{iac.name}}-{{instance.key}}{{count}}-{{disk.name}}"
{%     if disk.pool=="default" %}
  pool = "default"
{%     else %}
  pool = "{{iac.name}}-{{instance.value.provider.name|default(iac.providers[0].name)}}-{{disk.pool}}"
{%     endif %}
{%     if disk.base_volume|default(False) %}
  base_volume_id = libvirt_volume.{{iac.name}}-{{instance.value.provider.name|default(iac.providers[0].name)}}-{{disk.base_volume}}.id
{%     elif disk.source|default(False) %}
  source = "{{disk.source}}"
{%     endif %}
{%     if disk.size | default(False) %}
  size = "{{ disk.size|human_to_bytes }}"
{%     endif %}
}
{%   endfor %}

resource "libvirt_cloudinit_disk" "{{iac.name}}-{{instance.key}}{{count}}-cloudinit" {
  provider = libvirt.{{instance.value.provider.name|default(iac.providers[0].name)}}
  name           = "{{iac.name}}-{{instance.key}}{{count}}-cloudinit.iso"
  pool = "{{ instance.value.user_data_pool|default(instance.value.disks[0].pool|default('default')) }}"
  user_data      = <<EOF
#cloud-config
fqdn: "{{instance.key}}{{count}}.{{iac.name}}.{{iac.domain|default(default.iac.domain)}}"
{{instance.value.user_data|default(default.instance.user_data)|to_nice_yaml(indent=2)}}
EOF
}

# Define KVM domain to create
resource "libvirt_domain" "{{iac.name}}-{{instance.key}}{{count}}" {
  provider = libvirt.{{instance.value.provider.name|default(iac.providers[0].name)}}
  name   = "{{iac.name}}-{{instance.key}}{{count}}"
  description = "cluster: {{iac.name}}\nhostname: {{instance.key}}{{count}}.{{iac.name}}.{{iac.domain|default(default.iac.domain)}}\nroles: {{instance.value.roles|default(['base'])|join(',')}}\n"
  memory = "{{ instance.value.resources.mem|default(default.instance.resources.mem) }}"
  vcpu   = "{{ instance.value.resources.cpu|default(default.instance.resources.cpu) }}"

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

{%   if instance.value.user_data|default(default.instance.user_data) %}
  cloudinit = libvirt_cloudinit_disk.{{iac.name}}-{{instance.key}}{{count}}-cloudinit.id
{%   endif %}

{%   for disk in instance.value.disks|default(default.instance.disks) %}
  disk {
    volume_id = libvirt_volume.{{iac.name}}-{{instance.key}}{{count}}-{{disk.name}}.id
    scsi      = "true"
    wwn       = "{{ '%016d' % loop.index0 }}"
  }
{%   endfor %}


{%   for network in instance.value.networks|default(default.instance.networks) %}
  network_interface {
{%     if network.name!="default" %}
    network_name = "{{iac.name}}-{{instance.value.provider.name|default(iac.providers[0].name)}}-{{network.name}}"
{%     else %}
    network_name = "default"
{%     endif %}
{%     if network.mac_prefix|default(false) %}
{%       if count < 10 %}
    mac            = "{{network.mac_prefix}}:0{{count}}"
{%       elif count < 100 %}
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

