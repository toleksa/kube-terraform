#!/bin/bash

if [ $# -lt 1 ]; then
  echo "usage: $0 <env> [apply|destroy]"
  exit 0
fi

ENV_DIR="$1"

if [ ! -d "env/$ENV_DIR" ]; then
  echo "ERR: env/$ENV_DIR dir not found"
  exit 1
fi

if [ ! -d "env/$ENV_DIR/.terraform" ]; then
  echo "INFO: env/$ENV_DIR/.terraform not found, initializing terraform"
  TF_DATA_DIR=env/$ENV_DIR/.terraform terraform init --backend-config="path=env/$ENV_DIR/terraform.tfstate"
  RC=$?
  if [ $RC -ne 0 ]; then
    echo "ERR: terraform init RC=$RC"
    exit 2
  fi
  echo "INFO: init finished"
fi

CMD="TF_DATA_DIR=env/$ENV_DIR/.terraform terraform ${2:-apply} -var-file=env/$ENV_DIR/variables.tfvars" #--backend-config=\"path=env/$ENV_DIR/terraform.tfstate\" -var-file=env/$ENV_DIR/variables.tfvars"
echo "EXEC: $CMD"
eval $CMD

