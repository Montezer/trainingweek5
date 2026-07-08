# Training Week 5 – Tuesday 7th July

## Overview

Today’s session focused on:

- 
- 
- 

---

## Key Topics Covered

### 1. Topic Name

#### What is it?

Write a simple explanation in your own words.

#### Why is it useful?

Explain where/why this is used in DevOps, cloud, automation, deployment, or software development.

#### Key Commands / Syntax

```bash
sudo nano /etc/mongod.conf

```
- Change bindIp to 0.0.0.0
```
sudo cp /etc/mongod.conf /etc/mongod.conf.bak
 
```
- To make sure we still have the original copy

```
cat /etc/mongod.conf | grep bindIp
```
- Shows that value/change we configured to bindIp

#### Get App to connect to DB
1. DB VM running first
2. In the app folder: make sure its the IP for the DB instance
- export MONGODB_URI=mongodb://108.131.96.131:27017/tictactoe
- printenv MONGODB_URI

#### Troubleshoot app not connecting to DB
- Enviroment Variable - is it set correctly? does it have the right IP address? 
- DB security group rules? 
* Does the app run without the database?
* BindIP - set correctly?
* Is the database actually running?

#### General troubleshooting advice
 
* Is it a systematic approach?
* What is easiest thing to check?
* What is most likely thing it could be?
* Will your approach lead to the root cause of the problem? 

What we will do? 
* concentrate on load testing
* use a tool called Apache Bench (ab)
* taking note of what happens to the CPU usage as we load test

#### Using Apache Bench to do load testing

#### Installing Apache Bench

#### Doing the load testing

Format for `ab` command: 
```
ab -n 1000 -c 100 http://yourwebsite.com/
```

Examples of commands to run: 
ab -n 1000 -c 100 http://54.170.31.74/

ab -n 10000 -c 200 http://54.170.31.74/

ab -n 20000 -c 300 http://54.170.31.74/