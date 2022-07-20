#!/bin/bash

ansible-playbook -i inventory deploy.yaml --extra-vars "variable_host=virtbox"

