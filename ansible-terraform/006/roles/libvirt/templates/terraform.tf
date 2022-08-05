terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "{{ libvirt.config.source|default(default.libvirt.config.source) }}"
      version = "{{ libvirt.config.version|default(default.libvirt.config.version) }}"
    }
  }
}

terraform {
  backend "local" {}
}

