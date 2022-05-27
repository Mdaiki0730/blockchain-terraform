output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_public_2a_id" {
  value = aws_subnet.public_2a.id
}

output "subnet_public_2c_id" {
  value = aws_subnet.public_2c.id
}

output "subnet_private_2a_id" {
  value = aws_subnet.private_2a.id
}

output "subnet_private_2c_id" {
  value = aws_subnet.private_2c.id
}

output "route_table_private_2a_id" {
  value = aws_route_table.private_2a.id
}

output "route_table_private_2c_id" {
  value = aws_route_table.private_2c.id
}
