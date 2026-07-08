# Tic Tac Toe App — MongoDB VM Provisioning and App Connection

## Aim

The aim of this task was to provision a MongoDB database VM using a Bash script, then update the Tic Tac Toe app VM so that the app connects to the database and runs in database mode.

The final goal was to have:

```text
Browser
   ↓
App VM running Tic Tac Toe
   ↓
MongoDB VM storing app data
```

---

## Overview of What I Built

I created two separate EC2 instances:

| VM | Purpose |
|---|---|
| DB VM | Runs MongoDB |
| App VM | Runs the Tic Tac Toe Node.js app |

The database VM was provisioned using a Bash script called:

```bash
prov-db.sh
```

The app VM was then configured to connect to MongoDB using the `MONGODB_URI` environment variable.

---

## Part 1 — MongoDB Database VM

### DB VM Requirements

The MongoDB VM needed to be fully configured so that the app VM could connect to it, even after the DB VM was restarted.

The script needed to:

- Run `apt update`
- Run `apt upgrade`
- Install MongoDB
- Configure MongoDB to listen on all network interfaces using `bindIp: 0.0.0.0`
- Start MongoDB
- Enable MongoDB so it starts automatically after reboot

---

## Part 2 — MongoDB Provisioning Script

The database provisioning script was called:

```bash
prov-db.sh
```

### Example Script

```bash
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
```

---

## Part 3 — Testing the DB Script on the Current DB VM

After creating the script, I made it executable:

```bash
chmod +x prov-db.sh
```

Then I ran it:

```bash
./prov-db.sh
```

Once the script finished, I checked that MongoDB was running:

```bash
sudo systemctl status mongod
```

Expected result:

```text
active (running)
```

I also checked that MongoDB was listening on port `27017`:

```bash
sudo ss -tulnp | grep 27017
```

Expected result:

```text
0.0.0.0:27017
```

This showed that MongoDB was accepting connections from outside the VM.

---

## Part 4 — Checking the MongoDB Config

I checked the MongoDB config file:

```bash
sudo nano /etc/mongod.conf
```

The important part was:

```yaml
net:
  port: 27017
  bindIp: 0.0.0.0
```

This is needed because the app VM is a different machine, so MongoDB cannot only listen on `127.0.0.1`.

---

## Part 5 — Security Group Rules for DB VM

The DB VM security group needed to allow MongoDB traffic on port `27017`.

For testing, I used:

| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | My IP |
| Custom TCP | TCP | 27017 | App VM / testing source |

During testing, port `27017` was opened so the app VM could connect to the database.

A better security setup would be to only allow port `27017` from the app VM security group, rather than from everywhere.

---

## Part 6 — Fresh DB VM Test

After confirming the script worked on the current DB VM, I backed up the script to my local machine and deleted the test DB VM.

Then I launched a fresh Ubuntu EC2 instance and copied the script onto it.

Example copy command:

```bash
scp -i ~/.ssh/montezer-tech610-key.pem prov-db.sh ubuntu@DB_PUBLIC_IP:~
```

Then I SSH'd into the fresh DB VM:

```bash
ssh -i ~/.ssh/montezer-tech610-key.pem ubuntu@DB_PUBLIC_IP
```

I made the script executable again:

```bash
chmod +x prov-db.sh
```

Then I ran it:

```bash
./prov-db.sh
```

I checked MongoDB again:

```bash
sudo systemctl status mongod
```

Result:

```text
MongoDB was active and running
```

I also confirmed the bind IP was correct:

```bash
sudo grep bindIp /etc/mongod.conf
```

Expected result:

```text
bindIp: 0.0.0.0
```

---

## Part 7 — Getting the DB IP Address

For the app to connect to the database, I needed the DB VM IP address from AWS.

Example:

```text
DB Private IP: 172.31.57.34
```

I used the **private IP** because both the app VM and DB VM were running inside AWS in the same VPC.

The public IP can also work if MongoDB is configured correctly and port `27017` is open, but the private IP is better practice because:

- the database traffic stays inside AWS
- the DB does not need to be exposed publicly
- it is safer than relying on public internet access
- it is the normal approach when one EC2 instance connects to another EC2 instance in the same VPC

The important thing to remember is that the IP address is instance-specific. If I delete the DB VM and create a new one, I need to update the connection string with the new DB VM private IP.

---

## Part 8 — Connecting the App to MongoDB Manually

On the app VM, I went into the app folder:

```bash
cd /home/ubuntu/tech610-tic-tac-toe/app
```

Then I exported the MongoDB connection string using the DB VM private IP:

```bash
export MONGODB_URI=mongodb://DB_PRIVATE_IP:27017/tictactoe
```

Example:

```bash
export MONGODB_URI=mongodb://DB_PRIVATE_IP:27017/tictactoe
```

I checked that it was set correctly:

```bash
printenv MONGODB_URI
```

Expected result:

```text
mongodb://DB_PRIVATE_IP:27017/tictactoe
```

Then I started the app with PM2:

```bash
pm2 start index.js --update-env
```

If the app was already running, I restarted it with the environment variable:

```bash
pm2 delete all
MONGODB_URI=mongodb://DB_PRIVATE_IP:27017/tictactoe pm2 start index.js --update-env
pm2 save
```

This manual method was useful for testing Deliverable 1 because it proved the app could connect to the fresh DB VM.

---
## Part 9 — Testing the App

On the app VM, I checked PM2:

```bash
pm2 list
```

Expected result:

```text
index online
```

Then I checked Nginx:

```bash
sudo systemctl status nginx
```

Expected result:

```text
active (running)
```

Then I tested the app locally:

```bash
curl localhost
```

Finally, I opened the app in the browser using the app VM public IP:

```text
http://APP_PUBLIC_IP
```

The app loaded successfully and was using the MongoDB database connection.

---

## Part 11 — Troubleshooting Notes

### 502 Bad Gateway

If I saw:

```text
502 Bad Gateway
```

That meant Nginx was working, but the Node.js app was not running properly on port `3000`.

Fix:

```bash
cd /home/ubuntu/tech610-tic-tac-toe/app
pm2 delete all
MONGODB_URI=mongodb://DB_PRIVATE_IP:27017/tictactoe pm2 start index.js --update-env
pm2 save
sudo systemctl restart nginx
```

---

### MongoDB Connection Issue

If the app could not connect to MongoDB, I checked:

```bash
sudo systemctl status mongod
```

Then I checked if MongoDB was listening:

```bash
sudo ss -tulnp | grep 27017
```

I also checked the bind IP:

```bash
sudo grep bindIp /etc/mongod.conf
```

Expected result:

```text
bindIp: 0.0.0.0
```

---

### Environment Variable Issue

If the app was not using database mode, I checked:

```bash
printenv MONGODB_URI
```

If it was empty, I exported it again:

```bash
export MONGODB_URI=mongodb://DB_PRIVATE_IP:27017/tictactoe
```

Then restarted the app with PM2:

```bash
pm2 delete all
MONGODB_URI=mongodb://DB_PRIVATE_IP:27017/tictactoe pm2 start index.js --update-env
pm2 save
```

---

## Final Deliverable

Once the DB script worked on a fresh DB VM and the app script worked on a new app VM, the deliverable message was:

```text
DB script works, app script works + connects app to database
```

With the app link:

```text
http://APP_PUBLIC_IP
```

---

## Summary

In this task, I successfully:

- Created a MongoDB provisioning script
- Installed MongoDB using Bash
- Configured MongoDB to listen on `0.0.0.0`
- Started and enabled the MongoDB service
- Tested the script on a fresh DB VM
- Connected the Tic Tac Toe app to MongoDB using `MONGODB_URI`
- Tested the app in database mode using the `MONGODB_URI` environment variable
- Tested the app successfully through the browser

This completed the database provisioning and app-to-database connection task.