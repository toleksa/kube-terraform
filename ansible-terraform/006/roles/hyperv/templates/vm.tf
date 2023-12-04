# https://github.com/taliesins/terraform-provider-hyperv/tree/master

{% for count in range(instance.value.count|default(default.instance.count)) %}

{%   for disk in instance.value.disks|default(default.instance.disks) %}
resource "hyperv_vhd" "{{iac.name}}-{{instance.key}}{{count}}-{{disk.name}}" {
  path = "c:\\virtualki\\{{iac.name}}-{{instance.key}}{{count}}.vhdx" #Needs to be absolute path
  size = "{{ disk.size|human_to_bytes }}"
  source = "http://192.168.0.2:8765/hyperv/{{iac.name}}-{{instance.key}}{{count}}.vhdx"
}
{%   endfor %}

resource "hyperv_machine_instance" "{{iac.name}}-{{instance.key}}{{count}}" {
  name                   = "{{iac.name}}-{{instance.key}}{{count}}"
  generation             = 2
  processor_count        = {{ instance.value.resources.cpu|default(default.instance.resources.cpu) }}
  static_memory          = true
  memory_startup_bytes   = "{{ (instance.value.resources.mem|default(default.instance.resources.mem))*1024*1024 }}"
  memory_maximum_bytes   = "{{ (instance.value.resources.mem|default(default.instance.resources.mem))*1024*1024 }}"
  wait_for_state_timeout = 10
  wait_for_ips_timeout   = 10
  checkpoint_type        = "Disabled"
  notes                  = "cluster:{{iac.name}}\nhostname:{{instance.key}}{{count}}.{{iac.name}}.{{iac.domain|default(default.iac.domain)}}\nroles:{{instance.value.roles|default(['base'])|join(',')}}\n"

  vm_processor {
    expose_virtualization_extensions = false
  }

  integration_services = {
    "Guest Service Interface" = false
    "Heartbeat"               = true
    "Key-Value Pair Exchange" = true
    "Shutdown"                = true
    "Time Synchronization"    = true
    "VSS"                     = true
  }

  network_adaptors {
    name         = "eth0"
    switch_name  = "external"
    wait_for_ips = false
    dynamic_mac_address = false
    static_mac_address = "{{instance.value.networks.mac_prefix}}{{ '%02d' % count}}"
  }

{%   for disk in instance.value.disks|default(default.instance.disks) %}
  hard_disk_drives {
    controller_type     = "Scsi"
    path                = hyperv_vhd.{{iac.name}}-{{instance.key}}{{count}}-{{disk.name}}.path
    controller_number   = 0
    controller_location = {{ loop.index0 }}
  }
{%   endfor %}

  dvd_drives {
    controller_number   = 0
    controller_location = 63
    path                = "c:\\virtualki\\{{iac.name}}-{{instance.key}}{{count}}.iso"
    resource_pool_name  = "Primordial"
  }

  vm_firmware {
    enable_secure_boot = "Off"
  }
}
{% endfor %}

