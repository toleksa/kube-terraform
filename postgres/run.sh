#!/bin/bash

terraform apply -auto-approve

sleep 60s

ansible-playbook -i ansible/inv ansible/install-postgres.yaml
ansible-playbook -i ansible/inv ansible/data-postgres.yaml
ansible-playbook -i ansible/inv ansible/replication-postgres.yaml

