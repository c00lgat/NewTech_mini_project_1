resource "aws_autoscaling_group" "flask_app" {
  max_size = 1
  min_size = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1

  vpc_zone_identifier = [var.subnet1, var.subnet2]

  launch_template {
    id = var.asg_launch_template
  }
}

resource "aws_autoscaling_attachment" "asg_lb_attach" {
  autoscaling_group_name = aws_autoscaling_group.flask_app.id
  lb_target_group_arn    = var.lb_arn
}