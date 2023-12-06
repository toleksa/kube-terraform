#!/usr/bin/env python3

import winrm
import base64
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

        #command = 'cp \\\\192.168.0.2\storage\kubernetes\hyperv\*iso c:\\virtualki\\'
        #command = 'Copy-Item \\\\192.168.0.2\\storage\\kubernetes\\hyperv\\*iso c:\\virtualki\\'
        command = "cmd.exe /c 'c:\\virtualki\get-iso.bat'"
        command = "Start-Process -FilePath 'c:\\virtualki\get-iso.bat' -Wait"
        #print(command)

        #ps_script = f'$command = "{command}"; Invoke-Expression -Command $command'
        ps_script = f'$command = "{command}"; Invoke-Expression -Command $command 2>&1'

        encoded_ps = base64.b64encode(ps_script.encode()).decode()
        encoded_ps_command = f"$command = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('{encoded_ps}')); Invoke-Expression $command"

        #result = session.run_ps(encoded_ps_command)
        #print(f"Output:\n{result.std_out.decode('utf-8')}")
        #print(f"Error:\n{result.std_err.decode('utf-8')}")
        #print(f"Return code: {result.status_code}")

        #result = session.run_cmd('c:\virtualki\get-iso.bat')

        ps_script = """
                    $src = "\\\\192.168.0.2\storage\kubernetes\hyperv\"
                    $tgt = "c:\\virtualki\"
                    Copy-Item -Path $src\*iso -Destination $tgt -Force
                    """
        ps_script = """
                    $src = "c:\\virtualki\hyperv"
                    $tgt = "c:\\virtualki\"
                    Copy-Item -Path $src\*iso -Destination $tgt -Force
                    """
        #print(ps_script)
        result = session.run_ps(ps_script)

        print(result.std_out.decode())
        #print(result)
        #print(f"Output:\n{result.std_out.decode('utf-8')}")
        #print(f"Error:\n{result.std_err.decode('utf-8')}")
        #print(f"Return code: {result.status_code}")
        

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    dotenv_path = join(dirname(__file__), '.env')
    load_dotenv(dotenv_path)

    HYPERV_HOST = os.environ.get("TF_VAR_HYPERV_HOST")
    HYPERV_USER = os.environ.get("TF_VAR_HYPERV_USER")
    HYPERV_PASS = os.environ.get("TF_VAR_HYPERV_PASS")

    list_hyper_v_machines(HYPERV_HOST, HYPERV_USER, HYPERV_PASS)

