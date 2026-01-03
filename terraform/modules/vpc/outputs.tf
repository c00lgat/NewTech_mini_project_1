output "vpc_id" {
  value = aws_vpc.main.id
}

output "internet_gw_id" {
  value = aws_internet_gateway.gw.id
}

output "public_subnet_ids" {
  value = [aws_subnet.main.id, aws_subnet.secondary.id]
}