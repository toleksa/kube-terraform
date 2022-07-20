#!/bin/bash

if [ $# -ne 1 ]; then
  echo "ERR: usage: $0 <cluster>"
  exit 1
fi

ansible-playbook -i inventory deploy.yaml --extra-vars "variable_host=$1"

