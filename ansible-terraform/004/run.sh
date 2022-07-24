#!/bin/bash

if [ $# -lt 1 ]; then
  echo "ERR: usage: $0 <cluster> [apply|destroy]"
  exit 1
fi

if [ "$2" == "destroy" ]; then
  terraform_action="destroy"
elif [ "$2" == "apply" ] || [ $# -eq 1 ]; then
  terraform_action="apply"
else
  echo "unrecognized command parameter"
  exit 2
fi

CMD="ansible-playbook -i inventory deploy.yaml --extra-vars \"variable_host=$1\" --extra-vars \"terraform_action=$terraform_action\""
echo $CMD
eval $CMD

