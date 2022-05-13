# vim: syntax=yaml
variable "cluster_name" {
  description = "name of cluster"
  default = "c1"
}
variable "cluster_domain" {
  description = "domain for cluster and nodes"
  default = "kube.ac"
}
variable "cluster_ip" {
  description = "IP range for metallb - currently only single ip range supported"
  default = "192.168.0.210-192.168.0.210"
}
variable "server_count" {
  description = "number of server nodes"
  default = 3
}
variable "server_vcpu" {
  description = "cpu assigned to server node"
  default = 3
}
variable "server_mem" {
  description = "memory assigned to server node"
  default = 4000
}
variable "worker_count" {
  description = "number of worker nodes"
  default = 0
}
variable "worker_vcpu" {
  description = "cpu number assigned to worker node"
  default = 3
}
variable "worker_mem" {
  description = "memory assigned to worker node"
  default = 4000
}
variable "libvirt_host" {
  description = "machine with libvirt"
  default = "qemu+ssh://root@192.168.0.3/system"
}
variable "os_image" {
  description = "OS disk image location"
  default = "http://192.168.0.2:8765/jammy-server-cloudimg-amd64-disk-kvm-50G.img"
}
variable "join_token" {
  description = "token to join rke2 cluster"
  default = "changeMePlz1234567890"
}
variable "ssh_password" {
  description = "root password" 
  default = "$6$rounds=4096$5w8BN.5vqNPJwABq$Zv/WAL9LZQi20YweSNy8AvR8.fIdVvDjBg8NYtSvSQ4wufQ6wz4U/MDRP949.LJvWwKNPI6d.e/SWc6rk/njm/"
}
variable "ssh_password_plain" {
  description = "plain root password" 
  default = "root"
}
