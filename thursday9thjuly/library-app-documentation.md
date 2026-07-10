# Library App Documentation 

AWS EC2 Instance: 
- Name: tech610-yourname-library-db
- AMI: Ubuntu Server 22.04 LTS
- Instance type: t3.micro
- Key pair: your existing key
- Security group:
  - SSH 22 from My IP
  - MYSQL 3306 from App VM security group/private IP later

SSH into DB VM: 
- ssh -i ~/.ssh/montezerr-tech610-key.pem ubuntu@34.253.189.237

Install MySQL on DB VM: 
```bash
sudo apt update -y
sudo apt install mysql-server -y
sudo systemctl enable mysql
sudo systemctl start mysql
sudo systemctl status mysql  
```

This is all for the DB VM. The App will be on a different VM. So we need MySQL to accept network connections. Just like before, we need to find and edit the config file and change the bindip address to `0.0.0.0`