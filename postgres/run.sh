#!/bin/bash

terraform apply -auto-approve

export ANSIBLE_CONFIG=./ansible/ansible.cfg
ansible-playbook -i ansible/inv ansible/wait-for-vm.yaml
ansible-playbook -i ansible/inv ansible/install-postgres.yaml
ansible-playbook -i ansible/inv ansible/data-postgres.yaml
ansible-playbook -i ansible/inv ansible/replication-postgres.yaml

echo "ANSIBLE_CONFIG=./ansible/ansible.cfg; ansible-playbook -i ansible/inv ansible/failover-and-recovery.yaml"
echo "OR"
echo "ANSIBLE_CONFIG=./ansible/ansible.cfg; ansible-playbook -i ansible/inv ansible/upgrade-postgres.yaml"
