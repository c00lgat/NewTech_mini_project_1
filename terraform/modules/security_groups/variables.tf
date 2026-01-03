variable "vpc_id" {
    type = string
    description = "The VPC ID where the security group will be created"
}

variable "pc_ip" {
    type = string 
    description = "Current PC IP to allow SSH into the EC2 only from my EC2" 
}

variable "alb_ingress_rules" {
    type = list(number)
    default = [80, 443]
}

variable "ec2_app_ingress_rules" {
    type = list(number)
    default = [5000]
}

variable "alb_ip" {
    type = string
    description = "The DNS of the ALB, will be passed to the SG of the EC2 where the application is going to run"
}