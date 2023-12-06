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
  CMD="ansible-playbook -i inventory/$1 provision.yaml --extra-vars \"variable_host=$1\" --extra-vars \"terraform_action=destroy\""
  echo "EXEC: $CMD"
  eval $CMD && if [[ "$1" == *hyperv* ]]; then echo "EXEC: reloading hyperv isos" ; ./reload.py ; fi #TODO: change this condition to sth more reliable
elif [ "$2" == "apply" ] || [ $# -eq 1 ]; then
  CMD="ansible-playbook -i inventory/$1 provision.yaml --extra-vars \"variable_host=$1\" --extra-vars \"terraform_action=apply\""
  echo "EXEC: $CMD"
  eval $CMD
  CMD="ansible-playbook -i inventory/$1 deploy.yaml"
  echo "EXEC: $CMD"
  eval $CMD
else
  echo "unrecognized command parameter"
  exit 2
fi

