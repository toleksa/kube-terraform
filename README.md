# kube-terraform

# client (this machine)
* install-terraform.sh
* get ansible

# server
adjust inv file
* ansible init-ubuntu.yaml to install libvirt

# deploy kubernetes:
* cd kube-vm ; terraform apply # to install rke2 with argocd
* cd nginx ; terraform apply # to deploy nginx
