resource "oci_core_instance" "vm1" {
    availability_domain = var.availablity_domain_name
    compartment_id = var.compartment_ocid
    shape = var.instance_shape
    source_details {
        source_id = var.instance_source
        source_type = "image"
    }

    # Optional
    display_name = "vm1"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = "ocid1.subnet.oc1.eu-zurich-1.aaaaaaaaper3h2lyrziuh7llervqaksc6yz46czyrrwy5gti2dmz2dw4q43a"
    }
    shape_config {
        #Optional
        memory_in_gbs = 1
        ocpus = 1
    }
    metadata = {
        ssh_authorized_keys = file(var.ssh_authorized_keys)
    } 
    preserve_boot_volume = false
}

# Outputs
output "compute_id" {
  value = oci_core_instance.vm1.id
}

output "instance_state" {
  value = oci_core_instance.vm1.state
}

output "compute_public_ip" {
  value = oci_core_instance.vm1.public_ip
}

