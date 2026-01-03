variable "amazon_linux_ami_id" {
  type    = string
  default = "ami-08d7aabbb50c2c24e"
}

variable "key_location" {
  type    = string
  default = "~/.ssh/terraform_demo.pub"
}

variable "security_group_ids" {
  type = list(string)
}