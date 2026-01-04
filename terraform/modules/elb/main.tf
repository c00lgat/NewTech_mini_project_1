resource "aws_lb" "internet_facing" {
  name               = "flask-terraform-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = var.elb_sg
  subnets         = var.subnets
}

resource "aws_lb_listener" "HTTP_listener" {
  load_balancer_arn = aws_lb.internet_facing.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_asg_target_group.arn
  }
}

# resource "aws_lb_listener" "HTTPS_listener" {
#   load_balancer_arn = aws_lb.internet_facing.arn
#   port              = "443"
#   protocol          = "HTTPS"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.alb_asg_target_group.arn
#   }
# }

resource "aws_lb_target_group" "alb_asg_target_group" {
  name     = "app-target-group"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health"
  }
}

