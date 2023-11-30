terraform {
  required_version = ">= 0.13"
  required_providers {
    hyperv = {
      source = "{{ hyperv.config.source|default(default.hyperv.config.source) }}"
      version = "{{ hyperv.config.version|default(default.hyperv.config.version) }}"
    }
  }
}

terraform {
  backend "local" {}
}

