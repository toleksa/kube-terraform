#!/usr/bin/env python
### conf section
#NAME_FILTER = ''
STATE_MASK = None
STATE_MASK = [0,1,2,3,4,5,6,7,8]
#NAME_FILTER = '^exphost-.*'
#CLUSTER_NAME= 'exphost-dev'
#TODO: doesn't work with default, non-bridge network
OUTPUT_FORMAT='ssh'
#TODO: doesn't work with ansible.builtin.template task
#OUTPUT_FORMAT='libvirt'

import libvirt
import re
import json
import yaml
import jinja2
import os

def lookup(type, key):
    if type=="env":
        return os.environ.get(key)
    return None

IAC_PROFILE = os.getenv('IAC_PROFILE') 

if IAC_PROFILE == None:
    print("INFO: $IAC_PROFILE is empty, getting CWD name")
    IAC_PROFILE = os.path.dirname(__file__).split(os.sep)[-1]
    print(IAC_PROFILE)

with open(os.path.dirname(__file__) + "/group_vars/" + IAC_PROFILE + "/iac.yaml", "r") as f:
    iac = yaml.safe_load(f)
    CLUSTER_NAME = jinja2.Template(iac['iac']['name']).render(lookup=lookup)
    URI = []

    for provider in iac['iac']['providers']:
        if provider['type'] == 'libvirt':
            URI.append(provider['config'])

#URI = ["qemu+ssh://root@192.168.0.4/system"]
#CLUSTER_NAME='c0'

def libvirt_callback(userdata, err):
    pass

libvirt.registerErrorHandler(f=libvirt_callback, ctx=None)


#name_filter_re = re.compile(NAME_FILTER)

inventory = {}
inventory['all'] = {'hosts': []}

for u in URI:
    conn = libvirt.open(u)

    for domain in conn.listAllDomains():

        hostname = domain.name()
        try:
            metadata = (domain.metadata(type=0, uri=None)).split("\n")
            this_cluster = False
            for desc in metadata:
                if desc.startswith("cluster:"):
                    if desc.split("cluster:")[1].strip() == CLUSTER_NAME:
                        this_cluster = True
                if desc.startswith("hostname:") and OUTPUT_FORMAT != 'libvirt':
                    hostname = desc.split("hostname:")[1].strip()
            if not this_cluster:
                continue
        except libvirt.libvirtError:
            continue

        hostname = hostname.replace("_","-")

        if STATE_MASK and not domain.state()[0] in STATE_MASK:
            continue

        inventory['all']['hosts'].append(hostname)

        try:
            addresses = domain.interfaceAddresses(1)
            ### Take the eth0 interface
            ip_address = addresses['ens3']['addrs'][0]['addr']
            if "_meta" not in inventory:
                inventory['_meta'] = {'hostvars': {}}
            if domain not in inventory['_meta']['hostvars']:
                inventory["_meta"]['hostvars'][hostname] = {}
            if OUTPUT_FORMAT == 'ssh':
                inventory['_meta']['hostvars'][hostname]['ansible_host'] = ip_address
                inventory['_meta']['hostvars'][hostname]['ansible_user'] = "root"
            if OUTPUT_FORMAT == 'libvirt':
                inventory['_meta']['hostvars'][hostname]['ansible_connection'] = "community.libvirt.libvirt_qemu"
                inventory['_meta']['hostvars'][hostname]['ansible_libvirt_uri'] = "qemu+ssh://root@192.168.0.4/system"
                inventory['_meta']['hostvars'][hostname]['inventory_hostname'] = domain.name()
        except libvirt.libvirtError:
            pass

        try:
            metadata = domain.metadata(type=0, uri=None)
            for desc_line in metadata.split("\n"):
                if desc_line.startswith("roles: "):
                    roles = desc_line.split("roles:")[1].strip().split(",")
                    for role in roles:
                        if role not in inventory:
                            inventory[role] = {'hosts': []}
                        inventory[role]['hosts'].append(hostname)
                        
        except libvirt.libvirtError:
            pass

print(json.dumps(inventory, indent=4, sort_keys=True))

