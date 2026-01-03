resource "aws_launch_template" "flask_app_template" {
    description = "Launch template for the containerized flask app. This launch template will have Docker installed."
    name = "FlaskAppTemplate"

    instance_type = "micro.t3"
    image_id = var.amazon_linux_ami_id

    key_name = aws_key_pair.my_key

    vpc_security_group_ids = var.security_group_ids
    user_data = filebase64("${path.module}/user_data.sh")
}


resource "aws_key_pair" "my_key" {
  key_name = "my_key"
  public_key = file("${var.key_location}")
}