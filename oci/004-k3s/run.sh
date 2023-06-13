#!/bin/bash

while true; do
  terraform apply --auto-approve
  if [ $? -eq 0 ]; then
    /root/alert.sh "TA OCI is done"
    exit 0
  fi
  echo -e .
  sleep 10s
done
