#!/bin/bash

if [ $# -lt 1 ]; then
  echo "ERR: usage: $0 <cluster> [apply|destroy]"
  exit 1
fi

if [ ! -d "inventory/$1/group_vars/$1" ]; then
  echo "ERR: group_vars for $1 not found"
  exit 4
fi

export IAC_PROFILE="$1"

if [ ! -f .env ]; then
  echo "ERR: .env file missing"
  exit 3
fi

. .env

if [ "$2" == "destroy" ]; then
  terraform_action="destroy"
elif [ "$2" == "apply" ] || [ $# -eq 1 ]; then
  terraform_action="apply"
else
  echo "unrecognized command parameter"
  exit 2
fi

CMD="ansible-playbook -i inventory/$1 deploy.yaml --extra-vars \"variable_host=$1\" --extra-vars \"terraform_action=$terraform_action\""
echo "EXEC: $CMD"
eval $CMD

if [ "$terraform_action" == "apply" ]; then
  CMD="ansible-playbook -i inventory/$1 install.yaml"
  echo "EXEC: $CMD"
  eval $CMD
fi

