resource "oci_core_instance" "vm1" {
    availability_domain = var.availablity_domain_name
    compartment_id = var.compartment_ocid
    shape = "VM.Standard.E2.1.Micro"
    source_details {
        #https://docs.oracle.com/en-us/iaas/images/image/50672ce3-b252-4938-9099-06b938344302/
        #Oracle-Linux-8-2023.05.24-0
        source_id = "ocid1.image.oc1.eu-zurich-1.aaaaaaaa65hiqnviv765w3mjwyqzx64sgr6p2bsrwm63snsdqvtpl2lexyeq"
        source_type = "image"
    }

    # Optional
    display_name = "vm1"
    create_vnic_details {
        #assign_public_ip = true
        #subnet_id = "<subnet-ocid>"
    }
    metadata = {
        ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
    } 
    preserve_boot_volume = false
}
