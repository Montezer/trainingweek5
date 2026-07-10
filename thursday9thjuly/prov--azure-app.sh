#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh

sudo apt install nodejs nginx git -y

cd /home/adminuser

git clone https://github.com/davidrichardharvey/tech610-tic-tac-toe.git

cd tech610-tic-tac-toe/app

npm install

sudo npm install pm2 -g

export MONGODB_URI=mongodb://10.0.3.4:27017/tictactoe

pm2 kill

MONGODB_URI=mongodb://10.0.3.4:27017/tictactoe pm2 start index.js --update-env

pm2 save

sudo sed -i 's|try_files $uri $uri/ =404;|proxy_pass http://localhost:3000;|' /etc/nginx/sites-available/default

sudo systemctl restart nginx
sudo systemctl enable nginx

pm2 list