#!/bin/bash

COUNTER=0
while true; do
  terraform apply --auto-approve
  if [ $? -eq 0 ]; then
    /root/alert.sh "TA OCI is done"
    exit 0
  fi
  COUNTER=$((COUNTER+1))
  echo "counter: $COUNTER"
  sleep 10s
done
