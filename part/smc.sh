#!/bin/bash

sudo apt update
sudo apt install software-properties-common fail2ban -y
sudo apt-add-repository ppa:mkg20001/stable -y
sudo apt update
sudo apt install small-cleanup-script -y
small-cleanup-script
