# kube-terraform

## warning
ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain
* ```ssh-add ~/.ssh/id_rsa```


## client (this machine)
* ```install-terraform.sh```
* get ansible

## server (new host for libvirt)
* adjust inv file
* ```ansible-playbook -i inv init-ubuntu.yaml``` to install libvirt

## deploy kubernetes:
* ```cd kube-vm ; terraform apply``` # to install rke2 with argocd
* ```cd nginx ; terraform apply``` # to deploy nginx
