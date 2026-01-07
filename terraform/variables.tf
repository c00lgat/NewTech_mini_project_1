variable "aws_region" {
  default = "us-east-1"
}

variable "pc_ip" {
    default = "93.175.48.118/32"
}

variable "ssh_keys" {
  default = "/home/anan/.ssh/terraform_key.pub"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "asg_max_size" {
  type = number
}

variable "asg_min_size" {
  type = number
}

variable "asg_desired_capacity" {
  type = number
}