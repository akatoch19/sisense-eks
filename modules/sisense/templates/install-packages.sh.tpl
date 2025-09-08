#!/bin/bash
set -e

echo "Installing required packages on EKS nodes..."

# Install base packages
sudo dnf install -y gawk python3 python3-pip nc jq libselinux-python3 git

# Upgrade pip
sudo python3 -m pip install --upgrade --force-reinstall pip==21.1.3
sudo python3 -m pip install selinux

# Install sshpass
sudo dnf install -y https://rpmfind.net/linux/fedora/linux/releases/38/Everything/x86_64/os/Packages/s/sshpass-1.09-5.fc38.x86_64.rpm

# Install parallel SSH
sudo python3 -m pip install git+https://github.com/lilydjwg/pssh
sudo ln -sf /usr/bin/pip /usr/local/bin/pip
sudo python3 -m pip install --upgrade --force-reinstall pip
sudo python3 -m pip install configparser zipp

# Increase Docker ulimit
echo "Increasing Docker ulimit..."
sudo sed -i 's/--default-ulimit nofile=1024:4096/--default-ulimit nofile=1024000:1024000/' /etc/sysconfig/docker
sudo systemctl restart docker

# Configure DNS to use EC2 DNS server
echo "Configuring DNS..."
echo "nameserver 169.254.169.253" | sudo tee /etc/resolv.conf

echo "Package installation completed successfully!"
