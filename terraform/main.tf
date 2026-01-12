terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
  source = "./modules/security_groups"
  alb_ip = module.elb.aws_lb_ip
  pc_ip = var.pc_ip
  vpc_id = module.vpc.vpc_id
}

module "elb" {
    source = "./modules/elb"
    asg_target_group_id = module.asg.asg_id
    subnets = module.vpc.public_subnet_ids
    elb_sg = [module.security_groups.alb_sg]
    vpc_id = module.vpc.vpc_id
}

module "ec2_launch_template" {
    source = "./modules/ec2_launch_template"
    security_group_ids = [module.security_groups.ec2_app_ingress_rules]
    key_location = var.ssh_keys
    project = var.project
    environment = var.environment
    instance_type = var.instance_type
}

module "asg" {
    source = "./modules/asg"
    asg_launch_template = module.ec2_launch_template.template_id
    lb_arn = module.elb.target_group_arn
    subnet1 = module.vpc.public_subnet_ids[0]
    subnet2 = module.vpc.public_subnet_ids[1]
    asg_max_size = var.asg_max_size
    asg_min_size = var.asg_min_size
    asg_desired_capacity = var.asg_desired_capacity
}

module "ecr" {
  source = "./modules/ecr"
  repo_name = var.repo_name
}