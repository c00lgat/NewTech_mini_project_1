resource "aws_lb" "internet_facing" {
    name = "flask_terraform_alb"
    internal = false
    load_balancer_type = "application"

    security_groups = var.elb_sg
    
}