Project Overview: https://vimeo.com/1152552572?share=copy&fl=cl&fe=ci

### Provisioning the AWS Infrastructure (Terraform)

To provision the AWS environment shown in the diagram:
- Clone the repository
- Navigate into the Terraform directory:
  ```bash
  cd terraform
  ```
  
  Run a Terraform plan:
  ```bash
  terraform plan
  ```
During the plan/apply stage, Terraform may prompt you for input variables such as:

project → Project name (used for naming/tagging resources)

environment → Environment name (e.g. dev / prod)

instance_type → EC2 instance type to launch (e.g. t3.micro)

asg_max_size → Maximum number of EC2 instances the ASG can scale up to

asg_min_size → Minimum number of EC2 instances the ASG must keep running

asg_desired_capacity → Default number of EC2 instances the ASG should launch initially


  


## Architecture

This project provisions a highly-available AWS deployment in `us-east-1` using Terraform modules.

![Architecture diagram](docs/aws_architecture.svg)

**Networking**
- VPC: `10.0.0.0/16`
- Two public subnets across two AZs:
  - `us-east-1a`: `10.0.1.0/24`
  - `us-east-1b`: `10.0.2.0/24`
- Internet Gateway + public route table for internet connectivity

**Compute & Scaling**
- An Auto Scaling Group (ASG) manages EC2 instances.
- Instances are created using an EC2 Launch Template to ensure consistent configuration.

**Load Balancing**
- An Application Load Balancer (ALB) provides a stable DNS endpoint for end users.
- The ALB forwards traffic to the ASG instances (app listens on port `5000`) and performs health checks via `/health`.

**Security**
- Security groups separate public ingress (ALB) from application ingress (EC2).
- EC2 instances accept app traffic only from the ALB security group.
