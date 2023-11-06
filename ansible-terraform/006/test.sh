#!/bin/bash

#terraform apply --auto-approve
./run.sh ivy2 apply --auto-approve

URL="argocd.c2.kube.ac"
until curl --output /dev/null --silent --head --fail "$URL" ; do
    sleep 1s
    echo -n .
done ; echo OK

ssh-keygen -R s0.c2.kube.ac
ssh -o StrictHostKeyChecking=accept-new root@s0.c2.kube.ac "while argocd app list | grep -v HEALTH | grep -v Healthy > /dev/null ; do sleep 1s ; echo -n . ; done ; argocd app list"

