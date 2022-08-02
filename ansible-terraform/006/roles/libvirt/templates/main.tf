# vim: syntax=yaml
provider "{{ provider['type'] }}" {
    alias = "{{ provider['name'] }}"
    uri = "{{ provider['config'] }}"
}

{% for pool in iac.pools|default([]) %}
{%   if pool['name']!="default" %}

resource "libvirt_pool" "{{iac.name}}-{{provider['name']}}-{{ pool['name'] }}" {
  provider = {{ provider['type'] }}.{{ provider['name'] }}
  name = "{{iac.name}}-{{provider['name']}}-{{ pool['name'] }}"
  type = "dir"
  path = "{{ pool['path'] }}"
}
{%   endif %}
{% endfor %}

{% for network in iac.networks|default([]) %}
{%   if network['name']!="default" %}

resource "libvirt_network" "{{iac.name}}-{{provider['name']}}-{{ network['name'] }}" {
  provider = {{ provider['type'] }}.{{ provider['name'] }}
  name = "{{iac.name}}-{{provider['name']}}-{{network['name'] }}"
  mode = "bridge"
  bridge = "{{ network['bridge'] }}"
  autostart = "true"
}
{%   endif %}
{% endfor %}

{% for volume in iac.volumes|default([]) %}

resource "libvirt_volume" "{{iac.name}}-{{provider['name']}}-{{ volume['name'] }}" {
  provider = {{ provider['type'] }}.{{ provider['name'] }}
  name = "{{iac.name}}-{{provider['name']}}-{{ volume['name'] }}"
  source = "{{ volume['source'] }}"
  format = "{{ volume['format'] }}"
{%   if volume['pool']=="default" %}
  pool = "default"
{%   else %}
  pool = "{{iac.name}}-{{ volume['pool'] }}"
{%   endif %}
}

{% endfor %}

