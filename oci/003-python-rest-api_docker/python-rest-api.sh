#!/bin/bash

dnf install -y dnf-utils zip unzip ;\
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo ;\
dnf remove -y runc ;\
dnf install -y docker-ce --nobest ;\
systemctl enable docker.service ;\
systemctl start docker.service ;\
curl -L https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose ;\
chmod +x /usr/local/bin/docker-compose ;\
dnf install -y git ;\
git clone https://github.com/toleksa/python-rest-api.git ;\
cd python-rest-api/ ;\
PUBLIC_IP=`cat /home/opc/public_ip`; sed -i "s/\${HOSTNAME}/${PUBLIC_IP}/g" docker-compose.yaml
nohup /usr/local/bin/docker-compose up &


#missing: 
#- app deployment
#- www API_URL
#- security_list ports

