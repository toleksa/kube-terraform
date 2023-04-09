variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "fingerprint" {}
variable "ssh_authorized_keys" {}
variable "private_key_path" {}
variable "user_ocid" {}
variable "availablity_domain_name" {
  default = ""
}
variable "instance_shape" {
  default = "VM.Standard.E2.1.Micro"
}
variable "instance_source" {
  #Oracle-Linux-8.7-2023.05.24-0
  default = "ocid1.image.oc1.eu-zurich-1.aaaaaaaad5t3txkxdpokv5ejxodnwl4nx3xyyme3bvl2u5sauqjdyv4dtpba"
}
