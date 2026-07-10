# Azure 2-Tier Deployment - Tic Tac Toe App

## Task Overview

The task was to re-do the previous 2-tier deployment on a different cloud provider.

Cloud provider used:

```text
Azure
```

Region used:

```text
UK South
```

The aim of this task was to consolidate the previous deployment work and prove that the app and database could be deployed quickly using existing scripts.

The application deployed was the Sparta Global Tic Tac Toe app with MongoDB persistence and an Nginx reverse proxy.

---

## Final Result

The app was successfully deployed on Azure and connected to MongoDB.

Evidence that the app was connected to the database:

```text
Mode: Persistent with Mongo DB
```

The global scoreboard also showed a saved score, proving that the app was writing to and reading from MongoDB.

App link:

```text
http://85.210.16.172
```

---

## Architecture

The deployment used a 2-tier architecture:

```text
User/browser
    |
    v
App VM - public subnet
    |
    v
Database VM - private subnet
```

The app VM was public-facing and accessible from the browser.

The database VM was placed in the private subnet and the app connected to MongoDB using the database VM's private IP address.

---

## Azure Resource Group

All resources were created inside the cohort resource group:

```text
tech610
```

A new resource group was not created because we did not have permission to create our own.

---

## SSH Key Pair

A new SSH key pair was created locally for Azure using Ed25519 format.

Command used:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/tech610-azure-key
```

This created two files:

```text
~/.ssh/tech610-azure-key
~/.ssh/tech610-azure-key.pub
```

The public key was copied into Azure when creating the VMs.

The private key stayed on the local machine and was used to SSH into the app VM.

Example SSH command:

```bash
ssh -i ~/.ssh/tech610-azure-key adminuser@85.210.16.172
```

---

## Virtual Network Setup

Azure does not automatically provide a default VNet in the same way AWS provides a default VPC for quick EC2 deployments.

For this task, I created my own Azure Virtual Network.

### VNet Details

```text
Name: tech610-montezer-2-subnet-vnet
Address space: 10.0.0.0/16
Region: UK South
Resource group: tech610
```

### Subnets

Two subnets were created inside the VNet.

| Subnet name | Address range | Purpose |
|---|---:|---|
| public-subnet | 10.0.2.0/24 | App VM |
| private-subnet | 10.0.3.0/24 | Database VM |

The app VM was placed in the public subnet.

The database VM was placed in the private subnet.

---

## VNet Address Space Warning

While creating the VNet, Azure displayed a warning that the address space overlapped with another VNet in the same resource group.

The warning appeared because another VNet was also using:

```text
10.0.0.0/16
```

This did not affect the task because the VNets were not being peered or connected.

However, I learnt that overlapping address spaces would become a problem if the VNets needed to be connected later using VNet peering.

In a professional environment, address spaces should be planned properly to avoid overlap.

For this training task, I followed the required specification and kept:

```text
10.0.0.0/16
```

---

## VM Configuration

Both VMs used the required Azure VM configuration.

| Setting | Value |
|---|---|
| Region | UK South |
| Image | Ubuntu Server 24.04 LTS - x64 Gen2 |
| Security type | Standard |
| Size | Standard_B1s |
| Username | adminuser |
| Disk | Standard SSD |
| Authentication | SSH public key |
| Tag | Owner: Montezer |

I avoided Ubuntu Pro because it was not required and would cost more.

I also changed the disk from Premium SSD to Standard SSD to avoid unnecessary cost.

---

## App VM Setup

The app VM was created in the public subnet.

| Setting | Value |
|---|---|
| VM name | tech610-montezer-app-vm |
| Subnet | public-subnet |
| Public IP | Yes |
| Public inbound ports | SSH 22, HTTP 80 |

The app VM needed a public IP so the app could be accessed in a browser.

Nginx was used as a reverse proxy so the app could be accessed on port 80 instead of port 3000.

---

## Database VM Setup

The database VM was created in the private subnet.

| Setting | Value |
|---|---|
| VM name | tech610-montezer-db-vm |
| Subnet | private-subnet |
| Private IP | 10.0.3.4 |
| MongoDB port opened publicly | No |

The MongoDB port was not opened publicly because the database should not be exposed to the internet.

The app connected to MongoDB using the private IP address:

```text
10.0.3.4
```

---

## Why MongoDB Port 27017 Was Not Opened

The task specifically said not to allow the MongoDB port.

In AWS, I previously had to create a Security Group rule to allow the app VM to access the database VM on port 27017.

In Azure, this was not needed in the same way because Azure allows internal traffic within the same Virtual Network by default.

Because both VMs were inside the same VNet, the app VM could connect to MongoDB privately using:

```text
mongodb://10.0.3.4:27017/tictactoe
```

The important point is that port 27017 did not need to be opened to the internet.

---

## Accessing the Database VM

Because the database VM was private, I could not SSH into it directly from my local machine using the private IP.

This would not work from my local PC:

```bash
ssh -i ~/.ssh/tech610-azure-key adminuser@10.0.3.4
```

The reason is that `10.0.3.4` is a private IP address inside the Azure VNet.

Instead, I SSH'd into the public app VM first, then SSH'd from the app VM into the private database VM.

Flow:

```text
Local PC
   |
   v
App VM using public IP
   |
   v
Database VM using private IP
```

This made the app VM act like a jump box/bastion host.

---

## SSH Key Issue and Fix

When trying to SSH into the database VM from the app VM, I first got an error because the private key did not exist on the app VM.

Example error:

```text
Warning: Identity file /home/adminuser/.ssh/tech610-azure-key not accessible: No such file or directory.
Permission denied (publickey).
```

This happened because the private key was on my local machine, not on the app VM.

To fix this, I copied the private key from my local machine to the app VM temporarily:

```bash
scp -i ~/.ssh/tech610-azure-key ~/.ssh/tech610-azure-key adminuser@85.210.16.172:~
```

Then from the app VM, I fixed the key permissions:

```bash
chmod 400 ~/tech610-azure-key
```

After that, I could SSH into the database VM:

```bash
ssh -i ~/tech610-azure-key adminuser@10.0.3.4
```

After finishing the task, the copied private key should be removed from the app VM:

```bash
rm ~/tech610-azure-key
```

---

## Private Key Permissions Blocker

When attempting to use the copied private key, I got this warning:

```text
WARNING: UNPROTECTED PRIVATE KEY FILE!
Permissions 0644 for '/home/adminuser/tech610-azure-key' are too open.
This private key will be ignored.
```

This happened because SSH private keys must not be readable by other users.

The fix was:

```bash
chmod 400 ~/tech610-azure-key
```

After setting the correct permissions, SSH allowed the key to be used.

---

## Database Deployment Script

The database VM used a MongoDB installation script tested on Ubuntu 24.04 Noble.

The script installed MongoDB 8.2.5 and configured MongoDB to listen on all interfaces so the app VM could connect to it using the private IP.

Important MongoDB config change:

```bash
sudo sed -i 's/^[[:space:]]*bindIp:.*/  bindIp: 0.0.0.0/' /etc/mongod.conf
```

This changed MongoDB from only listening locally to listening for connections from the app VM inside the VNet.

The database script then started and enabled MongoDB:

```bash
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl restart mongod
```

MongoDB was confirmed as running:

```text
Active: active (running)
```

MongoDB version installed:

```text
db version v8.2.5
```

---

## Database VM Internet Access Blocker

The biggest blocker was that the database VM could not access the internet at first.

When running the database script, `apt update` failed with errors like:

```text
Could not connect to azure.archive.ubuntu.com:80
Unable to connect to azure.archive.ubuntu.com:http:
```

This happened because the database VM was in a private subnet with:

```text
No public IP
No NAT Gateway
No other outbound internet route
```

A private subnet does not automatically mean the VM can access the internet. It needs an outbound path.

This is similar to AWS: a private EC2 instance needs a NAT Gateway or similar outbound route to download packages.

### Fix

I temporarily associated a public IP with the database VM so it could download and install MongoDB packages.

Temporary public IP name used:

```text
tech610-montezer-db-temp-ip
```

After MongoDB installed successfully, the temporary public IP should be removed so the database VM remains private.

### Professional Note

The better long-term solution would be to use a NAT Gateway for the private subnet.

That would allow the database VM to access the internet for package updates without exposing it directly to the internet.

For this training task, temporarily adding and then removing the public IP was the quickest workaround.

---

## App Deployment Script

The app VM used the Tic Tac Toe app deployment script.

The original script needed a few changes because it was originally written for AWS.

### Important Changes Made

The username/path changed from:

```bash
cd /home/ubuntu
```

to:

```bash
cd /home/adminuser
```

This is because the Azure VM username was set to:

```text
adminuser
```

The MongoDB URI also changed from the old AWS private IP to the Azure database private IP.

Old AWS example:

```bash
MONGODB_URI=mongodb://172.31.48.134:27017/tictactoe
```

Azure version:

```bash
MONGODB_URI=mongodb://10.0.3.4:27017/tictactoe
```

---

## Corrected App Script Used

```bash
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
```

---

## Reverse Proxy Setup

Nginx was used as a reverse proxy.

This means the Node.js app runs on port 3000 internally, but users access it through normal HTTP on port 80.

The Nginx config was changed using:

```bash
sudo sed -i 's|try_files $uri $uri/ =404;|proxy_pass http://localhost:3000;|' /etc/nginx/sites-available/default
```

Then Nginx was restarted and enabled:

```bash
sudo systemctl restart nginx
sudo systemctl enable nginx
```

This allowed the app to be accessed through:

```text
http://85.210.16.172
```

instead of:

```text
http://85.210.16.172:3000
```

---

## Testing

### Check MongoDB

On the database VM:

```bash
sudo systemctl status mongod
```

Expected result:

```text
Active: active (running)
```

### Check PM2

On the app VM:

```bash
pm2 list
```

Expected result:

```text
online
```

### Check Nginx

On the app VM:

```bash
sudo systemctl status nginx
```

Expected result:

```text
Active: active (running)
```

### Browser Test

In the browser:

```text
http://85.210.16.172
```

The app loaded successfully.

The footer showed:

```text
Mode: Persistent with Mongo DB
```

This confirmed that the app was connected to MongoDB.

The scoreboard also showed a saved score:

```text
MON 300
```

This confirmed that the app could persist data to the database.

---

## Blockers Faced

### Blocker 1: SSH key path typo

I first tried to SSH using:

```bash
ssh -i /.ssh/tech610-azure-key adminuser@85.210.16.172
```

This was wrong because `/.ssh` means the `.ssh` folder at the root of the filesystem.

The correct path was:

```bash
ssh -i ~/.ssh/tech610-azure-key adminuser@85.210.16.172
```

The `~` points to the home directory.

---

### Blocker 2: Private key was not on the app VM

When trying to SSH from the app VM to the database VM, the key was missing.

Fix:

```bash
scp -i ~/.ssh/tech610-azure-key ~/.ssh/tech610-azure-key adminuser@85.210.16.172:~
chmod 400 ~/tech610-azure-key
ssh -i ~/tech610-azure-key adminuser@10.0.3.4
```

---

### Blocker 3: Private key permissions were too open

SSH refused to use the private key because the permissions were too open.

Fix:

```bash
chmod 400 ~/tech610-azure-key
```

---

### Blocker 4: DB VM had no outbound internet

The database VM could not run `apt update` properly because it had no outbound internet route.

Fix:

A temporary public IP was associated with the database VM so MongoDB could be installed.

After installation, the temporary public IP should be removed.

---

### Blocker 5: Azure username was different from AWS

The old script used:

```bash
cd /home/ubuntu
```

But Azure used:

```text
adminuser
```

Fix:

```bash
cd /home/adminuser
```

---

### Blocker 6: Old AWS MongoDB private IP in script

The app script originally used an old AWS private IP:

```bash
mongodb://172.31.48.134:27017/tictactoe
```

Fix:

Updated it to the Azure database VM private IP:

```bash
mongodb://10.0.3.4:27017/tictactoe
```

---

### Blocker 7: Understanding why not to keep the DB public IP

The task did not explicitly say that the DB VM must have no public IP, but it did say the DB VM should go in the private subnet.

The proper final design is for the DB VM to be private and only reachable from inside the VNet.

A public IP was only used temporarily to install packages.

---

## AWS vs Azure Differences Noticed

| Area | AWS | Azure |
|---|---|---|
| Resource grouping | Resource Groups optional | Resource Groups required |
| Virtual network | VPC | VNet |
| Region used | Ireland | UK South |
| VM creation wording | Launch instance | Create VM |
| Security rules | Security Group | Network Security Group |
| Default username | ubuntu | adminuser for this task |
| VM size | t3.micro | Standard_B1s |
| Disk choice | EBS volume | Standard SSD selected manually |
| Database access | Security Group rule often needed | Internal VNet traffic allowed by default |
| Private subnet internet | Needs NAT Gateway | Also needs NAT Gateway or outbound route |

---

## Clean-Up

After the task was completed and evidence was captured, the Azure resources should be deleted to avoid unnecessary cost.


Only delete resources created for this task, such as:

```text
tech610-montezer-app-vm
tech610-montezer-db-vm
tech610-montezer-2-subnet-vnet
temporary DB public IP

```

Also remove the copied private key from the app VM:

```bash
rm ~/tech610-azure-key
```

---

## Final Summary

The Azure 2-tier deployment was completed successfully.

The app VM was deployed in the public subnet and exposed through Nginx on port 80.

The database VM was deployed in the private subnet and ran MongoDB.

The app connected to MongoDB using the database VM's private IP address.

The deployment was confirmed working because the app loaded in the browser and displayed:

```text
Mode: Persistent with Mongo DB
```

The scoreboard saved data, proving the app was connected to the database.