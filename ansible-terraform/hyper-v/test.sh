#!/bin/bash

./run.sh start

URL="argocd.c5.kube.ac"
until curl --output /dev/null --silent --head --fail "$URL" ; do
    sleep 1s
    echo -n .
done ; echo OK

ssh-keygen -R kube1.c5.kube.ac
ssh -o StrictHostKeyChecking=accept-new root@kube1.c5.kube.ac "while argocd app list | grep -v HEALTH | grep -v Healthy > /dev/null ; do sleep 1s ; echo -n . ; done ; argocd app list"

