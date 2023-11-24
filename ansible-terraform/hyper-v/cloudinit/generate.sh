#!/bin/bash

mkisofs -output /storage/storage/kubernetes/kube1.iso -volid cidata -joliet -rock meta-data network-config user-data

