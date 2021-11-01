#!/bin/bash

set -euo pipefail

# ubuntu
if [ -x /usr/bin/apt ]; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  apt install terraform
fi

# fedora
if [ -x /usr/bin/dnf ]; then
  dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
  dnf install terraform
fi

ssh-add ~/.ssh/id_rsa 

