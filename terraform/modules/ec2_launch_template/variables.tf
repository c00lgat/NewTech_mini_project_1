variable "amazon_linux_ami_id" {
  type    = string

  #Amazon Linux AMI
  # default = "ami-08d7aabbb50c2c24e"

  #Ubuntu LTS 24.04 AMI
  default = "ami-0ecb62995f68bb549"
}

variable "key_location" {
  type    = string
  description = "Path to the public key file. Supplemented by the root variables.tf"
}

variable "security_group_ids" {
  type = list(string)
  description = "The SG IDs for the EC2 instance template. SGs are created under the security_groups module."
}

variable "project" {
  type = string
  description = "Used to tag the launched EC2 from the template. This will include the project name"
}

variable "environment" {
  type = string
  description = "Used to tag the launched EC2 from the template. This will include the environment (dev/prod)"
}

variable "instance_type" {
  type = string
  description = "Instance family and size. This will supplemented from the tfvars in the root terraform directory."
}