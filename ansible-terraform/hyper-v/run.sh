#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <start|stop>"
  exit 0
fi

if [ "$1" == "stop" ]; then
  terraform destroy -auto-approve
  exit 0
fi

if [ "$1" == "start" ]; then
  terraform apply -auto-approve || exit 1
  exit 0
fi

