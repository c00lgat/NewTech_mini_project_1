output "vpc_id" {
  value = aws_vpc.main.id
}

output "internet_gw_id" {
    value = aws_internet_gateway.gw.id
}

output "public_subnet" {
    value = aws_subnet.main.id
}

output "secondary_public_subnet" {
  value = aws_subnet.secondary.id
}