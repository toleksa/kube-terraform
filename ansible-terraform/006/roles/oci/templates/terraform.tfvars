# Authentication
tenancy_ocid         = "ocid1.tenancy.oc1..aaaaaaaamoek3enzvp7mcplinmel5yndxjxokwnlxt2vh4rqsutblxsemxaq"
user_ocid            = "ocid1.user.oc1..aaaaaaaatd2nxc6gsjgr2lh5v2ucs4bqucx2szqw23hnsea6gzzltu3oumba"
fingerprint          = "ea:d8:1c:0b:24:89:8b:43:8d:89:23:a7:ad:96:5c:04"
private_key_path     = "~/.oci/key.pem"

# Compartment
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaamoek3enzvp7mcplinmel5yndxjxokwnlxt2vh4rqsutblxsemxaq"

# Region
region = "eu-zurich-1"

# Availablity Domain 
availablity_domain_name = "nvfE:EU-ZURICH-1-AD-1"

# Instance
#https://docs.oracle.com/en-us/iaas/images/
#Oracle-Linux-8.7-2023.05.24-0  
#instance_source   = "ocid1.image.oc1.eu-zurich-1.aaaaaaaad5t3txkxdpokv5ejxodnwl4nx3xyyme3bvl2u5sauqjdyv4dtpba" #amd64
#instance_source   = "ocid1.image.oc1.eu-zurich-1.aaaaaaaa65hiqnviv765w3mjwyqzx64sgr6p2bsrwm63snsdqvtpl2lexyeq" #arm
#Canonical-Ubuntu-22.04-2023.06.30-0
instance_source   = "ocid1.image.oc1.eu-zurich-1.aaaaaaaad2jc5rvb4jvxzf32vc3eyfsasdlsmwtauvqx2e3ink2jfi3vhn7q" #amd64
instance_shape    = "VM.Standard.E2.1.Micro"
#instance_shape    = "VM.Standard.A1.Flex"
ssh_authorized_keys   = "~/.ssh/id_rsa.pub"

