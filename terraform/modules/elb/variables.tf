variable "elb_sg" {
  type        = list(string)
  description = "The SG ID for the ALB"
}

variable "subnets" {
  type        = list(string)
  description = "The target subnets that the ALB will be forwarding traffic to."
}

variable "asg_target_group_id" {
  type        = string
  description = "The ID of the ASG for it to be registered as a target group"
}

variable "vpc_id" {
  type = string
}