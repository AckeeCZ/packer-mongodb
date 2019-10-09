#!/bin/bash

version=${MONGO_VER:=3.2}

apt-get update || echo "this is for VM images only"
apt-get install -y sudo || echo "this is for VM images only"

sudo apt-get update
sudo apt-get install -y wget software-properties-common lsb-release perl curl pwgen sysstat

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 #3.2
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 #3.4
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/${version} multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org.list

sudo apt-get -qq update

# set transparent_hugepage/enabled and transparent_hugepage/defrag to never
echo never > sudo tee /sys/kernel/mm/transparent_hugepage/enabled
echo never > sudo tee /sys/kernel/mm/transparent_hugepage/defrag

DEBIAN_FRONTEND=noninteractive  sudo apt-get install -y mongodb-org

echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections

sudo mkdir /etc/systemd/system/mongod.service.d
sudo mv /tmp/systemd-override.conf /etc/systemd/system/mongod.service.d/override.conf

sudo systemctl start mongod.service

DEBIAN_FRONTEND=noninteractive  sudo apt-get install -y nmap htop pigz ncdu
DEBIAN_FRONTEND=noninteractive  sudo apt-get -y dist-upgrade

cat << EOF > /tmp/createuser
db.createUser(
   {
     user: "root",
     pwd: "thispasswordisnotverysecretitwillbechanged",
     roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
   }
)
EOF

sudo mongo admin < /tmp/createuser
rm /tmp/createuser
