cd /home/ubuntu/tech610-tic-tac-toe/app
pm2 start index.js
pm2 save
sudo systemctl restart nginx


# updated image

#!/bin/bash

cd /home/ubuntu/tech610-tic-tac-toe/app

pm2 delete all

MONGODB_URI=mongodb://NEW_DB_PRIVATE_IP:27017/tictactoe pm2 start index.js --update-env

pm2 save

systemctl restart nginx