#!/usr/bin/env python3

import winrm
import base64
import json
import os
from os.path import join, dirname
from dotenv import load_dotenv

def list_hyper_v_machines(host, username, password):
    try:
        # Create a session with the remote machine using pywinrm
        session = winrm.Session(
            host, 
            auth=(username, password),
            server_cert_validation='ignore'  # Use this option if you encounter SSL certificate validation issues
        )

        # Construct the PowerShell script to query Hyper-V machines
        ps_script = """
        $vms = Get-VM
        $output = @()

        foreach ($vm in $vms) {
            $vmInfo = @{
                Name = $vm.Name
                Status = $vm.State
                Notes = $vm.Notes -join ', '
            }

            $output += $vmInfo
        }

        $output | ConvertTo-Json
        """

        # Encode the PowerShell script in base64
        encoded_ps = base64.b64encode(ps_script.encode()).decode()
        encoded_ps_command = f"$command = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('{encoded_ps}')); Invoke-Expression $command"

        result = session.run_ps(encoded_ps_command)

        inventory = {}
        inventory['all'] = {'hosts': []}
        inventory['_meta'] = {'hostvars': {}}
        domains = json.loads(result.std_out.decode())
        if isinstance(domains, dict):
            domains = [domains]
        for domain in domains:
            notes = domain['Notes'].split('\n')
            if notes==['']:
                continue
            d = {}
            for note in notes:
                if note:
                    key, value = note.split(":")
                    d[key]=value
            if d['cluster']=='c5': #TODO hardcoded cluster
                inventory['all']['hosts'].append(d['hostname'])
                inventory['_meta']['hostvars'][d['hostname']] = {'ansible_host': d['hostname'], 'ansible_user': 'root'}
                for role in d['roles'].split(','):
                    if role not in inventory:
                        inventory[role] = {'hosts': []}
                    inventory[role]['hosts'].append(d['hostname'])

        print(json.dumps(inventory, indent=4, sort_keys=True))

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    dotenv_path = join(dirname(__file__), '.env')
    load_dotenv(dotenv_path)

    HYPERV_HOST = os.environ.get("HYPERV_HOST")
    HYPERV_USER = os.environ.get("HYPERV_USER")
    HYPERV_PASS = os.environ.get("HYPERV_PASS")

    list_hyper_v_machines(HYPERV_HOST, HYPERV_USER, HYPERV_PASS)

