# Re-creating an AWS Auto Scaling Group

## Objective

The aim of this task is to deploy a highly available and scalable application using:

- An EC2 launch template
- An EC2 Auto Scaling Group
- An Application Load Balancer
- A target group
- Health checks
- A scaling policy
- Instances in at least two Availability Zones

The Auto Scaling Group should:

1. Maintain the required number of EC2 instances.
2. replace an instance when it becomes unhealthy.
3. add more instances when demand increases.
4. remove extra instances when demand decreases.
5. send users only to healthy application instances.


# Important concepts

## What is an Auto Scaling Group?

An Auto Scaling Group, or ASG, manages a collection of EC2 instances as one logical group.

It can:

- maintain a minimum number of instances.
- keep a desired number of instances running.
- prevent the number of instances exceeding a maximum.
- launch instances when demand increases.
- terminate instances when demand falls.
- replace instances that fail health checks.

---

## What is a launch template?

A launch template is the reusable configuration that the Auto Scaling Group uses when creating EC2 instances.

It normally contains:

- The image ID;
- instance type;
- SSH key pair;
- the security group;
- storage settings;
- user data;
- IAM role, if required.

Every instance launched by the ASG should be created from the same template. This makes the deployment consistent and repeatable.

---