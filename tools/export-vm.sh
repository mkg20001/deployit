#!/bin/bash

set -ex

VBoxManage export DevVM2 -o devvm2.installed.ova --options nomacs
tar cvf devvm2.ova.tar.bz2 -I pbzip2 devvm2.installed.ova
rm devvm2.installed.ova
