variable "asg_launch_template" {
  type        = string
  description = "The ID of the ASG launch template"
}

variable "lb_arn" {
  type = string
}

variable "subnet1" {
  type = string
}

variable "subnet2" {
  type = string
}