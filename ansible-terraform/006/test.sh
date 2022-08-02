#!/bin/bash

#terraform apply --auto-approve
./run.sh virtbox apply --auto-approve

URL="argocd.c0.kube.ac"
until curl --output /dev/null --silent --head --fail "$URL" ; do
    sleep 1s
    echo -n .
done

