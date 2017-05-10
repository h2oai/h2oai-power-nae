#!/bin/bash

# Change Nginx Redirect
sudo sed -e 's/8888/12345/' -i /etc/nginx/sites-enabled/default
sudo sed -e 's/8888/12345/' -i /etc/nginx/sites-enabled/notebook-site
sudo service ssh restart
sudo /usr/sbin/nginx

sudo rm -f /etc/NAE/url.txt
sudo echo "http://%PUBLICADDR%:12345/" > /etc/NAE/url.txt

cd /opt/h2oai  
/usr/bin/python3.6 -m h2o 
