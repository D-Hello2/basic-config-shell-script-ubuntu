#!/bin/bash

echo "provisioning ubuntu created by dani"
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
read -p "ip address ( example: 10.10.10.1/24 ): " ip1
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
for ii in {1..$numint};
do
sudo cat << EOF | sudo tee -a /etc/hosts
$(hostname -I | awk '{print $ii}') $(hostname) 
EOF
echo ""
sleep 1
done

read -p "do you want to update the system and install some packages? (y/n) : " update1
if [ $update1 == "y" ] || [ $update1 == "Y" ]; then 
read -p "name packages ( example: apache2 w3m ): " packages1
echo "update"
sudo apt update
sudo apt install $packages1 -y
echo ""
echo "done"

elif [ $update1 == "n" ] || [ $update1 == "N" ]; then
echo "ok"

else
echo "please input y/n"

fi

exec bash
