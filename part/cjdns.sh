#!/bin/bash

cd /opt
sudo git clone https://github.com/cjdelisle/cjdns.git
cd cjdns
sudo ./do
sudo ln -s /opt/cjdns/cjdroute /usr/bin
sudo cp contrib/systemd/cjdns.service /etc/systemd/system/
sudo cp contrib/systemd/cjdns-resume.service /etc/systemd/system/
sudo systemctl enable cjdns
sudo systemctl start cjdns
