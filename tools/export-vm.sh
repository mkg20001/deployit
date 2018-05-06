#!/bin/bash

set -ex

VBoxManage export "$VM_NAME" -o "$VM_FILE.installed.ova" --options nomacs
tar cvf "$VM_FILE.ova.tar.bz2" -I pbzip2 "$VM_FILE.installed.ova"
rm "$VM_FILE.installed.ova"
