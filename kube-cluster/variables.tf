# vim: syntax=yaml

variable "env" {
  description = "set environment"
  default = "virtbox"
}
variable "cluster_name" {
  description = "name of cluster"
  default = "c0"
}
variable "cluster_domain" {
  description = "domain for cluster and nodes"
  default = "kube.ac"
}
variable "cluster_ip" {
  description = "IP range for metallb - currently only single ip range supported"
  default = "192.168.0.200-192.168.0.200"
}
variable "mac_prefix" {
  description = "prefix for network card mac addr"
  default = "44:8a:5b:00:03"
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
  default = 3
}
variable "worker_vcpu" {
  description = "cpu number assigned to worker node"
  default = 3
}
variable "worker_mem" {
  description = "memory assigned to worker node"
  default = 4000
}
variable "network_bridge" {
  description = "network for domain - 'default' for default network, any other variable will create bridged network based on given interface"
  default = "br0"
}
variable "pool_name" {
  description = "disk pool - 'default' for default pool, any other variable will create new pool for cluster"
  default = "default"
}
variable "pool_path" {
  description = "path used for creating new pool - ignored when pool_name = 'default'"
  default = "/virtualki/kube-cluster"
}
variable "libvirt_host" {
  description = "machine with libvirt"
  default = "qemu+ssh://root@192.168.0.4/system"
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
