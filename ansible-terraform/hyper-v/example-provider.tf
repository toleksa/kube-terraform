provider "hyperv" {
  user            = "user"
  password        = "pass"
  host            = "host"
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

