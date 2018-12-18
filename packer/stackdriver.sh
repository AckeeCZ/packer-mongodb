#!/bin/bash

#!/bin/bash

echo "deb http://packages.cloud.google.com/apt google-cloud-monitoring-$(lsb_release -sc) main" | sudo tee --append /etc/apt/sources.list.d/google-cloud-monitoring.list
echo "deb http://packages.cloud.google.com/apt google-cloud-logging-wheezy main" | sudo tee --append /etc/apt/sources.list.d/google-cloud-logging.list
curl --connect-timeout 5 -s -f "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo apt-key add -
sudo apt-get -qq update
DEBIAN_FRONTEND=noninteractive sudo apt-get -y -q install stackdriver-agent google-fluentd google-fluentd-catch-all-config
DEBIAN_FRONTEND=noninteractive sudo apt-get clean
sudo rm -Rf /var/lib/apt/lists/*

cd /opt/stackdriver/collectd/etc/collectd.d/ 
sudo curl -O https://raw.githubusercontent.com/Stackdriver/stackdriver-agent-service-configs/master/etc/collectd.d/mongodb.conf
pass=$(pwgen 10 1)
sudo sed -i 's/#User "STATS_USER"/User "stackdriver"/g' mongodb.conf
sudo sed -i 's/#Password "STATS_PASS"/Password "'$pass'"/g' mongodb.conf

cat << EOF > /tmp/createuser
db.createUser(
   {
     user: "stackdriver",
     pwd: "$pass",
     roles: [ { role: "clusterMonitor", db: "admin" } ]
   }
)
EOF
sudo mongo admin < /tmp/createuser
rm /tmp/createuser