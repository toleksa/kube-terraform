#!/bin/bash

set -euo pipefail

# ubuntu
#curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
#apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
#apt install terraform

# fedora
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
dnf install terraform

#mkdir -p ~/.terraform.d/plugins/
#wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.11/terraform-provider-libvirt_0.6.11_linux_amd64.zip -O /tmp/terraform-libvirt.zip
#tar xvf terraform-provider-libvirt-0.6.0+git.1569597268.1c8597df.Fedora_28.x86_64.tar.gz
#mv terraform-provider-libvirt ~/.terraform.d/plugins/

ssh-add ~/.ssh/id_rsa 

