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
* ```cd kube-vm2 ; terraform apply``` # to install rke2 with argocd
* ```cd nginx ; terraform apply``` # to deploy nginx
* ```cd postgres ; ./run.sh``` # to deploy postgres11 cluster

## 192.168.0.2:8765 - secret repo, contains:
- dns <- dns key
- env-v1 <- env configs for instances
- env-v2
- ...
- focal-server-cloudimg-amd64-disk-kvm.img <- optional image for faster deploy, but I'm not sure if it's helping ;)
- ssh/postgres/ <- .ssh content

## hints
- adjust host_count: ```terraform apply -var="host_count=2"```

- create default pool:
```
virsh pool-define-as default dir - - - - /virtualki
virsh pool-build default
virsh pool-start default
virsh pool-autostart default
```
