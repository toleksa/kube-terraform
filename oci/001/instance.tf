resource "oci_core_instance" "vm1" {
    availability_domain = var.availablity_domain_name
    compartment_id = var.compartment_ocid
    shape = "VM.Standard.E2.1.Micro"
    source_details {
        #https://docs.oracle.com/en-us/iaas/images/image/50672ce3-b252-4938-9099-06b938344302/
        #Oracle-Linux-8.7-2023.05.24-0
        source_id = "ocid1.image.oc1.eu-zurich-1.aaaaaaaad5t3txkxdpokv5ejxodnwl4nx3xyyme3bvl2u5sauqjdyv4dtpba"
        source_type = "image"
    }

    # Optional
    display_name = "vm1"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = "ocid1.subnet.oc1.eu-zurich-1.aaaaaaaaper3h2lyrziuh7llervqaksc6yz46czyrrwy5gti2dmz2dw4q43a"
    }
    metadata = {
        ssh_authorized_keys = file(var.private_key_path)
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

