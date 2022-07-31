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

