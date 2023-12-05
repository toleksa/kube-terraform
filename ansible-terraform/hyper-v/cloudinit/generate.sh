#!/bin/bash

mkisofs -output /storage/storage/kubernetes/hyperv/kube1.iso -volid cidata -joliet -rock meta-data network-config user-data

