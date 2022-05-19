#!/bin/bash

echo "provisioning ubuntu"
echo ""
sleep 1

echo "Addusers"
echo ""
sleep 1

read -p "user: " userinput
read -s -p "pw: " passinput

sudo adduser $userinput << EOF
$passinput
$passinput
EOF
echo ""


echo "add user to sudo"
sudo echo "$userinput    ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
echo ""
sleep 1

read -p "Hostname: " hostnameinput
sudo hostnamectl set-hostname $hostnameinput
echo ""
sleep 1

echo "setting ip address"
read -p "number of interfaces: " numint

for i in {1..$numint};
do
  read -p "name interfaces: " int1
  read -p "ip address ( use /x ): " ip1
  read -p "gateway: " gateway1
  read -p "dns: " dns1
  sudo cat << EOF | sudo tee /etc/netplan/00-installer-config.yaml
  network:
    ethernets:
      $int1:
        dhcp4: no
        addresses:
          - $ip1
        gateway4: $gateway1
        nameservers:
          addresses: [$dns1] 
  EOF
  echo ""
  sleep 1
done

echo "restart network"
sudo netplan apply
echo ""
sleep 1

echo "mapping host"
sudo cat << EOF | sudo tee -a /etc/hosts
192.168.1.80 $HOSTNAME master
EOF
echo ""
sleep 1

echo "update"
sudo apt update
