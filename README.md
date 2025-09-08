# DEVOPS MASTER
So this repo is basically a practice project where I will be using all the Devops tools Kubernetes, Docker, docker-compose, Jenkins, Ansible, Grafana, Prometheus all in one repo the ultimate DEVOPS MASTER

## Project Overview

The flow of the project is as follows:

1. **Terraform** provisions the AWS infrastructure:
   - VPC with public and private subnets
   - Internet Gateway, NAT Gateways, and Route Tables
   - Security groups
   - Bastion host
   - EKS cluster and node group

2. **Bastion Host**
   - A golden image of a Ubuntu EC2 instance is created with:
     - `kubectl` installed and configured to connect to the EKS cluster
     - `awscli` installed and configured
     - `ansible` installed
     - `docker` and `docker-compose` installed
     - Jenkins installed via Docker Compose container

3. **Jenkins**
   - Runs inside a Docker container on the bastion host
   - AWS and GitHub credentials are configured in Jenkins
   - The pipeline Groovy file is saved in the repository at:  
     `jenkins/jenkins.groovy`
   - The Jenkins pipeline automates deployment tasks to EKS using Ansible and Helm (future stages)

4. **Golden Image**
   - Once all prerequisites are installed and Jenkins is configured, a golden AMI image is taken.
   - Any future bastion host creation can use this image to have Jenkins, Ansible, kubectl, and Docker ready to go.

---



## How It Works

1. **Terraform**
   - Run `terraform init` and `terraform apply` to create the infrastructure.
   - The bastion host will have a public IP and security group for SSH access.

2. **Bastion Host**
   - SSH into the bastion host.
   - The golden image already has kubectl, awscli, ansible, docker, docker-compose, and Jenkins installed.

3. **Jenkins**
   - Access Jenkins via `http://<bastion-public-ip>:8080`.
   - The pipeline in `jenkins/jenkins.groovy` defines all deployment steps.
   - AWS credentials and GitHub credentials are configured in Jenkins for automation.
