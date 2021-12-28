#!/bin/bash

kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- '-rc' | sort -r | head -1 | awk -F': ' '{print $2}' | sed 's/,//' | xargs)/kubevirt-operator.yaml
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- '-rc' | sort -r | head -1 | awk -F': ' '{print $2}' | sed 's/,//' | xargs)/kubevirt-cr.yaml
curl -L -o /usr/local/bin/virtctl https://github.com/kubevirt/kubevirt/releases/download/$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")/virtctl-$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")-$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/')
chmod +x /usr/local/bin/virtctl

