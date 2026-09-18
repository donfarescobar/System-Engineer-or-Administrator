output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value = {
    for zone, subnet in aws_subnet.zone : zone => subnet.id
  }
}