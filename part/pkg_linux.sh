#!/bin/bash

sudo snap install atom --classic
sudo snap install lxd juju
sudo apt install htop nload iotop nano nethogs curl wget -y

#docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#nodejs
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -

#dev stuff
sudo apt install nodejs git build-essential python2.7 -y

#moar packages
sudo apt install docker-ce -y
