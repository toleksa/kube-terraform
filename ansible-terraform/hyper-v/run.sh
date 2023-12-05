#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <start|stop>"
  exit 0
fi

if [ ! -f .env ]; then
  echo "ERR: .env file missing"
  exit 3
fi

. .env

if [ "$1" == "stop" ]; then
  terraform destroy -auto-approve
  exit 0
fi

if [ "$1" == "start" ]; then
  terraform apply -auto-approve || exit 1
  ansible-playbook -i inv install.yaml
  exit 0
fi

