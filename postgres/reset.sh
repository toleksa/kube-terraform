#!/bin/bash

ansible-playbook -i ansible/inv ansible/stop-and-reset.yaml
ansible-playbook -i ansible/inv ansible/install-postgres.yaml --skip-tags='repo'
ansible-playbook -i ansible/inv ansible/data-postgres.yaml
ansible-playbook -i ansible/inv ansible/replication-postgres.yaml

