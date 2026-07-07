# MongoDB Installation Script Notes

**Tested:** 06/07/2026  
**OS:** Ubuntu 24.04 Noble  
**MongoDB version:** 8.2.5  

This document explains the Bash script used to install and start MongoDB on an Ubuntu EC2 instance or VM.

---

## Full Bash Script

```bash
#!/bin/bash

# TESTED: 06/07/2026

echo "Updating the sources list..."
sudo apt update -y
echo "Done!"

echo "Upgrading the packages..."
sudo apt upgrade -y
echo "Done!"

echo "Installing MongoDB signing key..."
curl -fsSL https://pgp.mongodb.com/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor
echo "Done!"

echo "Creating MongoDB list file..."
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
echo "Done!"

echo "Updating package list..."
sudo apt-get update
echo "Done!"

echo "Installing MongoDB packages..."
sudo apt-get install -y \
   mongodb-org=8.2.5 \
   mongodb-org-database=8.2.5 \
   mongodb-org-server=8.2.5 \
   mongodb-mongosh \
   mongodb-org-shell=8.2.5 \
   mongodb-org-mongos=8.2.5 \
   mongodb-org-tools=8.2.5 \
   mongodb-org-database-tools-extra=8.2.5
echo "Done!"

echo "Starting MongoDB..."
sudo systemctl start mongod
echo "Done!"

echo "Enabling MongoDB to start on boot..."
sudo systemctl enable mongod
echo "Done!"

echo "Checking MongoDB service status..."
sudo systemctl status mongod

echo "Checking MongoDB version..."
mongosh --version
```

---

## What This Script Does

### 1. Updates the Package List

```bash
sudo apt update -y
```

This updates the local list of available packages from the Ubuntu repositories.

---

### 2. Upgrades Existing Packages

```bash
sudo apt upgrade -y
```

This upgrades installed packages to their latest available versions.

---

### 3. Adds the MongoDB Signing Key

```bash
curl -fsSL https://pgp.mongodb.com/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor
```

This downloads the MongoDB GPG signing key and stores it in the system keyrings directory.

The signing key allows Ubuntu to verify that the MongoDB packages are trusted and have not been tampered with.

---

### 4. Creates the MongoDB Repository List File

```bash
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
```

This adds the official MongoDB repository to Ubuntu.

The repository is needed because MongoDB is not installed directly from the default Ubuntu package sources.

---

### 5. Updates the Package List Again

```bash
sudo apt-get update
```

After adding the MongoDB repository, the package list must be updated again so Ubuntu can detect the new MongoDB packages.

---

### 6. Installs MongoDB Packages

```bash
sudo apt-get install -y \
   mongodb-org=8.2.5 \
   mongodb-org-database=8.2.5 \
   mongodb-org-server=8.2.5 \
   mongodb-mongosh \
   mongodb-org-shell=8.2.5 \
   mongodb-org-mongos=8.2.5 \
   mongodb-org-tools=8.2.5 \
   mongodb-org-database-tools-extra=8.2.5
```

This installs MongoDB and related tools.

| Package | Purpose |
|---|---|
| `mongodb-org` | Main MongoDB package |
| `mongodb-org-database` | MongoDB database components |
| `mongodb-org-server` | MongoDB server daemon |
| `mongodb-mongosh` | MongoDB shell used to interact with databases |
| `mongodb-org-shell` | MongoDB shell package |
| `mongodb-org-mongos` | MongoDB routing service for sharded clusters |
| `mongodb-org-tools` | MongoDB command-line tools |
| `mongodb-org-database-tools-extra` | Extra database tools |

---

## Starting and Enabling MongoDB

### Start MongoDB

```bash
sudo systemctl start mongod
```

This starts the MongoDB service immediately.

---

### Enable MongoDB on Boot

```bash
sudo systemctl enable mongod
```

This makes MongoDB start automatically whenever the VM or EC2 instance reboots.

---

### Check MongoDB Status

```bash
sudo systemctl status mongod
```

This checks whether MongoDB is currently running.

If MongoDB is working correctly, the status should show:

```bash
active (running)
```

---

## Check MongoDB Version

```bash
mongosh --version
```

This checks the installed MongoDB shell version.

> Note: `mongo --version` may not work on newer MongoDB installations because the older `mongo` shell has been replaced by `mongosh`.

---

## Important Notes

- The script uses the MongoDB 8.0 repository but installs MongoDB package version `8.2.5`.
- The server name for the MongoDB service is `mongod`.
- `mongosh` is the modern MongoDB shell command.
- This script is suitable for Ubuntu 24.04 Noble.

---

## Useful MongoDB Commands

### Start MongoDB

```bash
sudo systemctl start mongod
```

### Stop MongoDB

```bash
sudo systemctl stop mongod
```

### Restart MongoDB

```bash
sudo systemctl restart mongod
```

### Check MongoDB Status

```bash
sudo systemctl status mongod
```

### Open MongoDB Shell

```bash
mongosh
```

---

## Final Check

After running the script, check that MongoDB is running:

```bash
sudo systemctl status mongod
```

Then open the MongoDB shell:

```bash
mongosh
```

If the shell opens successfully, MongoDB has been installed and started correctly.
