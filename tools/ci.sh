#!/bin/bash

set -ex

if [ -z "$WIN10" ]; then
  export VM_NAME="DevVM2"
  export VM_FILE="devvm2"
else
  export VM_NAME="DevVM10"
  export VM_FILE="devvm10"
fi
[ -e tools ] && cd tools
VBoxManage unregistervm "$VM_NAME" --delete || echo "Didn't exist"
bash create-vm.sh
# Post-cleanup
VBoxManage storageattach "$VM_NAME" --storagectl SATA --port 1 --medium emptydrive
VBoxManage storageattach "$VM_NAME" --storagectl SATA --port 2 --medium none
VBoxManage storagectl "$VM_NAME" --name Floppy --remove
# Export
bash export-vm.sh
