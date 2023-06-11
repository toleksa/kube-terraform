# Define the Terraform provider
terraform {
  required_version = ">= 1.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
        version = ">= 5.2.0"
      }
    }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

