resource "aws_autoscaling_group" "flask_app" {
    max_size = 1
    min_size = 1

    health_check_grace_period = 300
    health_check_type = ELB
    desired_capacity = 1

    launch_template {
      id = var.ASG_launch_template
    }
}