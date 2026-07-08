cd /home/ubuntu/tech610-tic-tac-toe/app
pm2 start index.js
pm2 save
sudo systemctl restart nginx