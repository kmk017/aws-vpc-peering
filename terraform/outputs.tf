output "vpc_a_id" {
  description = "VPC A ID"
  value       = aws_vpc.vpc_a.id
}

output "vpc_b_id" {
  description = "VPC B ID"
  value       = aws_vpc.vpc_b.id
}

output "peering_connection_id" {
  description = "VPC peering connection ID"
  value       = aws_vpc_peering_connection.peer.id
}

output "peering_status" {
  description = "Provider-reported peering status; meaningful after apply"
  value       = aws_vpc_peering_connection.peer.accept_status
}

output "bastion_public_ip" {
  description = "Public IPv4 of bastion; assigned by AWS after apply"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "app_a_id" {
  value = aws_instance.app_a.id
}

output "app_a_private_ip" {
  value = aws_instance.app_a.private_ip
}

output "app_b_id" {
  value = aws_instance.app_b.id
}

output "app_b_private_ip" {
  value = aws_instance.app_b.private_ip
}
