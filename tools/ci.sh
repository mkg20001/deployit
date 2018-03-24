#!/bin/bash

set -ex

[ -e tools ] && cd tools
VBoxManage unregistervm DevVM2 --delete
bash create-vm.sh
# Post-cleanup
VBoxManage storageattach DevVM2 --storagectl SATA --port 1 --medium emptydrive
VBoxManage storageattach DevVM2 --storagectl SATA --port 2 --medium none
VBoxManage storagectl DevVM2 --name Floppy --remove
# Export
bash export-vm.sh
