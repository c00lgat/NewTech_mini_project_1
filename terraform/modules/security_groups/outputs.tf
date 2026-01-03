output "allow_ssh_sg_id" {
  value = aws_security_group.allow_ssh.id
}

output "alb_ingress_rules" {
  value = aws_security_group.alb_ingress_rules.id
}

output "ec2_app_ingress_rules" {
  value = aws_security_group.ec2_app_ingress_rules.id
}
