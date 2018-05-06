#!/bin/bash

set -ex

# VBoxManage createvm --name "$VM_NAME" --ostype Windows7_64 --register
[ ! -e gen.js ] && cd ..
VBoxManage import "$VM_FILE.ova"
DO_RUN=1 node gen.js windeploy
cd tools
VBoxManage startvm "$VM_NAME" --type headless
sleep 10s
set +x
echo "Waiting for setup to complete and VM to shut down..."
while ! VBoxManage showvminfo "$VM_NAME" --machinereadable --details | grep VMState= | grep poweroff > /dev/null 2> /dev/null; do
  echo -n .
  sleep 10s
done
sleep 1s
set -x
VBoxManage snapshot "$VM_NAME" take Setup
