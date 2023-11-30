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

variable "HYPERV_USER" {}
variable "HYPERV_PASS" {}
variable "HYPERV_HOST" {}

