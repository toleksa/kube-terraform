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

if [ "$2" == "init" ]; then
  echo "ERR: workspaces in use, don't use init"
  exit 0
fi

CMD="terraform workspace select $1"
echo "EXEC: $CMD"
eval $CMD || exit 1

CMD="terraform ${2:-apply} -var-file=env/$ENV_DIR/variables.tfvars"
echo "EXEC: $CMD"
eval $CMD

