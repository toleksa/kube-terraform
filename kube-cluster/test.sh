#!/bin/bash

terraform apply --auto-approve

URL="argocd.v1.kube.ac"
until curl --output /dev/null --silent --head --fail "$URL" ; do
    sleep 1s
    echo -n .
done

