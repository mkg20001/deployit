#!/bin/bash

set -ex

VBoxManage export DevVM2 -o devvm2.installed.ova --options nomacs
tar cvf devvm2.tar.bz2.ova -I pbzip2 devvm2.installed.ova
rm devvm2.installed.ova
