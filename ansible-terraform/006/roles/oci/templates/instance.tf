resource "oci_core_vcn" "vcn1" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "vcn1"
  dns_label      = "vcn1"
}

resource "oci_core_subnet" "subnet1" {
  cidr_block          = "10.0.0.0/24"
  display_name        = "subnet1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vcn1.id
  route_table_id      = oci_core_route_table.route_table1.id
  #security_list_ids   = [oci_core_vcn.vcn1.default_security_list_id,oci_core_security_list.security_list1.id]
  #security_list_ids   = [oci_core_vcn.vcn1.default_security_list_id]
  security_list_ids   = [oci_core_security_list.security_list1.id]
  dhcp_options_id     = oci_core_vcn.vcn1.default_dhcp_options_id
  dns_label           = "subnet1"
}

resource "oci_core_route_table" "route_table1" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn1.id

    #Optional
    display_name = "route_table1"
    route_rules {
        #Required
        network_entity_id = oci_core_internet_gateway.internet_gateway1.id

        #Optional
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }
}

resource "oci_core_internet_gateway" "internet_gateway1" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn1.id

    #Optional
    enabled = true
    display_name = "internet_gateway1"
}

resource "oci_core_security_list" "security_list1" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn1.id

    #Optional
    display_name = "security_list1"
    ingress_security_rules {
        #Required
        protocol = 6  #TCP
        source = "0.0.0.0/0"

        #Optional
        description = "http"
        source_type = "CIDR_BLOCK"
        stateless = false
        tcp_options {
            #Optional
            max = 80
            min = 80
        }
    }
    ingress_security_rules {
        #Required
        protocol = 6  #TCP
        source = "0.0.0.0/0"

        #Optional
        description = "http"
        source_type = "CIDR_BLOCK"
        stateless = false
        tcp_options {
            #Optional
            max = 22
            min = 22
        }
    }

    egress_security_rules {
        protocol = "all"  #6 TCP
        destination = "0.0.0.0/0"
    }
}

resource "oci_core_instance" "vm2" {
    availability_domain = var.availablity_domain_name
    compartment_id = var.compartment_ocid
    shape = var.instance_shape
    source_details {
        source_id = var.instance_source
        source_type = "image"
    }

    # Optional
    display_name = "vm2"
    create_vnic_details {
        assign_public_ip = true
        #subnet_id = "ocid1.subnet.oc1.eu-zurich-1.aaaaaaaaper3h2lyrziuh7llervqaksc6yz46czyrrwy5gti2dmz2dw4q43a"
        subnet_id = oci_core_subnet.subnet1.id
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
    freeform_tags = {"ansible_group": "oci"}
}

# Outputs
output "compute_id" {
  value = oci_core_instance.vm2.id
}

output "instance_state" {
  value = oci_core_instance.vm2.state
}

output "compute_public_ip" {
  value = oci_core_instance.vm2.public_ip
}

