#!/bin/bash

terraform apply --auto-approve -var="host_count=3"

for NUM in `seq 1 3`; do
  URL="argocd.v${NUM}.kube.ac"
  echo "waiting for $URL"
  until curl --output /dev/null --silent --head --fail "$URL" ; do
    sleep 1s
    echo -n .
  done
  echo ""
done

