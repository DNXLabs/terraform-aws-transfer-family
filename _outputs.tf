output "endpoint" {
  value = aws_transfer_server.default.endpoint
}

output "eip_allocation_ids" {
  description = "List of Elastic IP allocation IDs created for the Transfer Server"
  value       = aws_eip.transfer_server[*].allocation_id
}

output "eip_public_ips" {
  description = "List of Elastic IP public IPs created for the Transfer Server"
  value       = aws_eip.transfer_server[*].public_ip
}
output "transfer_server_id" {
  description = "The ID of the AWS Transfer Server"
  value       = aws_transfer_server.default.id
}
}