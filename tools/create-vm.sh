#!/bin/bash

set -ex

# VBoxManage createvm --name DevVM2 --ostype Windows7_64 --register
[ ! -e gen.js ] && cd ..
VBoxManage import devvm2.ova
DO_RUN=1 node gen.js windeploy
cd tools
VBoxManage startvm DevVM2 --type headless
sleep 10s
echo "Waiting for setup to complete and VM to shut down..."
while ! VBoxManage showvminfo DevVM2 --machinereadable --details | grep VMState= | grep poweroff > /dev/null 2> /dev/null; do
  echo -n .
  sleep 10s
done
sleep 1s
VBoxManage snapshot DevVM2 take Setup
