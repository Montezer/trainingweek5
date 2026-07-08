#!/bin/bash

apt update -y
apt upgrade -y

curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
bash nodesource_setup.sh

apt install nodejs nginx git -y

cd /home/ubuntu

git clone https://github.com/davidrichardharvey/tech610-tic-tac-toe.git

cd tech610-tic-tac-toe/app

npm install

npm install pm2 -g

pm2 kill
pm2 start index.js
pm2 startup systemd -u root --hp /root
pm2 save

sed -i 's|try_files $uri $uri/ =404;|proxy_pass http://localhost:3000;|' /etc/nginx/sites-available/default

systemctl restart nginx
systemctl enable nginx