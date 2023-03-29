variable "compute_shape" {
  type    = string
  default = "VM.Standard.E2.1.Micro"
}

variable "compute_cpus" {
  type    = string
  default = "1"
}

variable "compute_memory_in_gbs" {
  type    = string
  default = "1"
}


# Resources
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

resource "oci_core_instance" "tf_compute" {
  # Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  shape               = var.compute_shape

  source_details {
    source_id         = "ocid1.image.oc1.eu-zurich-1.aaaaaaaad5t3txkxdpokv5ejxodnwl4nx3xyyme3bvl2u5sauqjdyv4dtpba"
    source_type       = "image"
  }

  # Optional
  display_name        = "vm1"

  shape_config {
    ocpus         = var.compute_cpus
    memory_in_gbs = var.compute_memory_in_gbs
  }

  create_vnic_details {
    #subnet_id         = var.compute_subnet_id
    subnet_id         = "ocid1.subnet.oc1.eu-zurich-1.aaaaaaaaper3h2lyrziuh7llervqaksc6yz46czyrrwy5gti2dmz2dw4q43a"
    assign_public_ip  = true
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  } 

  preserve_boot_volume = false
}


# Outputs
output "compute_id" {
  value = oci_core_instance.tf_compute.id
}

output "db_state" {
  value = oci_core_instance.tf_compute.state
}

output "compute_public_ip" {
  value = oci_core_instance.tf_compute.public_ip
}

