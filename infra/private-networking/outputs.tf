output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "outbound_only_sg_id" {
  description = "ID of the outbound-only security group"
  value       = aws_security_group.outbound_only.id
}

output "availability_zone" {
  description = "The availability zone used for the subnets"
  value       = data.aws_availability_zones.available.names[0]
}