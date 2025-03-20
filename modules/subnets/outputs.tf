output "private_subnet_ids" {
  value = [for s in aws_subnet.main : s.id if s.map_public_ip_on_launch == false]
}
output "first_public_subnet_id" {
  value = element([for s in aws_subnet.main : s.id if s.map_public_ip_on_launch == true], 0)
}
output "public_subnet_ids" {
  value = [for s in aws_subnet.main : s.id if s.map_public_ip_on_launch == true]
}
output "subnet_ids" {
  value = [for s in aws_subnet.main : s.id]
}

output "pr_subnet_ids" {
  value = [for s in aws_subnet.main : s.id if s.map_public_ip_on_launch == false]
}
output "first_private_subnet_id" {
  value = element([for s in aws_subnet.main : s.id if s.map_public_ip_on_launch == false], 0)
}