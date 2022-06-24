env = "dedyk"
cluster_name = "dedyk"
cluster_domain = "lol"
cluster_ip = "192.168.0.200-192.168.0.200"
mac_prefix = "44:8a:5b:00:03"
server_count = 1
server_vcpu = 4
server_mem = 6000

worker_count = 0
worker_vcpu = 3
worker_mem = 4000

network_bridge = "default"

libvirt_host = "qemu+ssh://devops_together@65.108.231.102:2233/system"
#os_image = "http://192.168.0.2:8765/jammy-server-cloudimg-amd64-disk-kvm.img"
os_image = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"

join_token = "changeMePlz1234567890"

ssh_password = "$6$rounds=4096$5w8BN.5vqNPJwABq$Zv/WAL9LZQi20YweSNy8AvR8.fIdVvDjBg8NYtSvSQ4wufQ6wz4U/MDRP949.LJvWwKNPI6d.e/SWc6rk/njm/"
ssh_password_plain = "root"

