output "aws_lb_id" {
  value = aws_lb.internet_facing.id
}

output "aws_lb_ip" {
  value = aws_lb.internet_facing.dns_name
}

output "aws_lb_arn" {
  value = aws_lb.internet_facing.arn
}