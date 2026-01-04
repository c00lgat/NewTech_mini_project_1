variable "amazon_linux_ami_id" {
  type    = string

  #Amazon Linux AMI
  # default = "ami-08d7aabbb50c2c24e"

  #Ubuntu LTS 24.04 AMI
  default = "ami-0ecb62995f68bb549"
}

variable "key_location" {
  type    = string
  description = "Path to the public key file"
}

variable "security_group_ids" {
  type = list(string)
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