resource "aws_security_group" "allow_ssh" {
  name        = "allow SSH"
  description = "Allow SSH connections to the instance"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_rule" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = var.pc_ip
  ip_protocol       = "22"
}

resource "aws_security_group" "alb_sg" {
  name        = "alb_ingress_rules"
  description = "Allow HTTP/HTTPS traffic into the ALB"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  dynamic "ingress" {
    iterator = port
    for_each = var.alb_ingress_rules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_security_group" "ec2_app_ingress_rules" {
  name        = "app_ingress_rules"
  description = "Allows traffic on port 5000"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "TCP"
    security_groups = [aws_security_group.alb_sg.id]
    description = "Allow traffic only from the ALB"
  }
}
