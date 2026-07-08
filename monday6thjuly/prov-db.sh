#!/bin/bash

# TESTED: 07/07/2026
# OS: Ubuntu 24.04 Noble
# MongoDB version: 8.2.5

echo "Updating the sources list..."
sudo apt update -y
echo "Done!"

echo "Upgrading the packages..."
sudo apt upgrade -y
echo "Done!"

echo "Installing required packages..."
sudo apt install -y curl gnupg
echo "Done!"

echo "Installing MongoDB signing key..."
curl -fsSL https://pgp.mongodb.com/server-8.0.asc | \
sudo gpg --yes -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
echo "Done!"

echo "Creating MongoDB 8.2 list file..."
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.2 multiverse" | \
sudo tee /etc/apt/sources.list.d/mongodb-org-8.2.list
echo "Done!"

echo "Updating package list..."
sudo apt update -y
echo "Done!"

echo "Installing MongoDB 8.2.5 packages..."
sudo apt install -y \
   mongodb-org=8.2.5 \
   mongodb-org-database=8.2.5 \
   mongodb-org-server=8.2.5 \
   mongodb-mongosh \
   mongodb-org-shell=8.2.5 \
   mongodb-org-mongos=8.2.5 \
   mongodb-org-tools=8.2.5
echo "Done!"

echo "Setting MongoDB bindIp to 0.0.0.0..."
sudo cp /etc/mongod.conf /etc/mongod.conf.bak
sudo sed -i 's/^[[:space:]]*bindIp:.*/  bindIp: 0.0.0.0/' /etc/mongod.conf
echo "Done!"

echo "Starting MongoDB..."
sudo systemctl start mongod
echo "Done!"

echo "Enabling MongoDB to start on boot..."
sudo systemctl enable mongod
echo "Done!"

echo "Restarting MongoDB to apply config changes..."
sudo systemctl restart mongod
echo "Done!"

echo "Checking MongoDB service status..."
sudo systemctl status mongod --no-pager

echo "Checking MongoDB server version..."
mongod --version

echo "Checking MongoDB shell version..."
mongosh --version

echo "MongoDB installation complete!"