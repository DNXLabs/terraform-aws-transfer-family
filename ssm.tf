resource "tls_private_key" "sftp_ssh_key" {
  for_each  = { for user in var.sftp_users : user.username => user }
  algorithm = "RSA"
}

resource "aws_ssm_parameter" "sftp_users_public_ssh_key" {
  for_each    = { for user in var.sftp_users : user.username => user }
  name        = "/${var.account_name}/sftp/users/${each.value.username}/ssh_key_private"
  description = "Private SSH Key for user ${each.value.username}"
  type        = "SecureString"
  value       = tls_private_key.sftp_ssh_key[each.value.username].private_key_pem
}

resource "aws_ssm_parameter" "sftp_users_private_ssh_key" {
  for_each    = { for user in var.sftp_users : user.username => user }
  name        = "/${var.account_name}/sftp/users/${each.value.username}/ssh_key_public"
  description = "Public SSH Key for user ${each.value.username}"
  type        = "SecureString"
  value       = tls_private_key.sftp_ssh_key[each.value.username].public_key_openssh
}
