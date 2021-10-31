#!/bin/bash

if [ $# -ne 1 ]; then
  echo "usage: $0 <host>"
  exit 1
fi

scp root@$1:/etc/rancher/rke2/rke2.yaml .
sed -i "s/127.0.0.1:6443/kube-api.$1/" rke2.yaml 
