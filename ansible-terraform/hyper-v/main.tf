# https://github.com/taliesins/terraform-provider-hyperv/tree/master

terraform {
  required_providers {
    hyperv = {
      version = "1.0.3"
      source  = "registry.terraform.io/taliesins/hyperv"
    }
  }
}

provider "hyperv" {
  user            = var.HYPERV_USER
  password        = var.HYPERV_PASS
  host            = var.HYPERV_HOST
  port            = 5985
  https           = false
  insecure        = true
  use_ntlm        = true
  tls_server_name = ""
  cacert_path     = ""
  cert_path       = ""
  key_path        = ""
  #script_path     = "C:/Temp/terraform_%RAND%.cmd"
  timeout         = "30s"
}


#resource "hyperv_network_switch" "dmz_network_switch" {
#  name = "dmz"
#}

resource "hyperv_vhd" "kube1-disk" {
  #path = "c:\\virtualki\\jammy-server-cloudimg-amd64.vhdx" #Needs to be absolute path
  path = "c:\\virtualki\\kube1.vhdx" #Needs to be absolute path
  size = 53687091200 #50GB
  source = "http://192.168.0.2:8765/hyperv/kube1.vhdx"
}

#resource "hyperv_vhd" "kube1-cloudinit" {
#  path = "c:\\virtualki\\kube1.iso"
#  source = "http://192.168.0.2:8765/hyperv/kube1.iso"
#}

resource "hyperv_machine_instance" "kube1" {
  name                   = "kube1"
  generation             = 2
  processor_count        = 4
  static_memory          = true
  memory_startup_bytes   = 17179869184 #16GB
  memory_maximum_bytes   = 17179869184 #16GB
  wait_for_state_timeout = 10
  wait_for_ips_timeout   = 10
  checkpoint_type        = "Disabled"
  notes                  = "cluster:c7\nhostname:kube1.c7.kube.ac\nroles:argocd"

  vm_processor {
    expose_virtualization_extensions = false
  }

  integration_services = {
    "Guest Service Interface" = true
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
    static_mac_address = "DEAD010701AA"
  }

  hard_disk_drives {
    controller_type     = "Scsi"
    path                = hyperv_vhd.kube1-disk.path
    controller_number   = 0
    controller_location = 0
  }

  dvd_drives {
    controller_number   = 0
    controller_location = 1
    path                = "c:\\virtualki\\kube1.iso"
    #source = "http://192.168.0.2:8765/hyperv/kube1.iso"
    resource_pool_name  = "Primordial"
  }

  vm_firmware {
    enable_secure_boot = "Off"
  }
}

variable "HYPERV_USER" {}
variable "HYPERV_PASS" {}
variable "HYPERV_HOST" {}

