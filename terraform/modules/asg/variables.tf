variable "asg_launch_template" {
  type        = string
  description = "The ID of the ASG launch template"
}

variable "lb_arn" {
  type = string
  description = "The ARN of the LoadBalancer, used to associate the LB with the ASG via aws_autoscaling_attachment"
}

variable "subnet1" {
  type = string
  description = "One of the two subnets, used as a target subnet for the ASG EC2 deployment"
}

variable "subnet2" {
  type = string
  description = "One of the two subnets, used as a target subnet for the ASG EC2 deployment"
}

variable "asg_max_size" {
  type = number
  description = "The max number of instances to be deployed by the ASG"
}

variable "asg_min_size" {
  type = number
  description = "The min number of instances to be deployed by the ASG"
}

variable "asg_desired_capacity" {
  type = number
  description = "The desired number of instances to be deployed by the ASG"
}