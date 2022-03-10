resource "aws_transfer_server" "default" {
  identity_provider_type    = "SERVICE_MANAGED"
  protocols                 = ["SFTP"]
  endpoint_type             = "PUBLIC"
  force_destroy             = true
  security_policy_name      = var.security_policy_name
  logging_role              = join("", aws_iam_role.logging[*].arn)

  tags = {
    Name = var.server_name
  }
}

output "test" {
  value = var.sftp_users
}

resource "aws_transfer_user" "default" {
  for_each            = { for user in var.sftp_users : user.username => user }
  server_id           = join("", aws_transfer_server.default[*].id)
  role                = aws_iam_role.s3_access_for_sftp_users[each.value.username].arn
  user_name           = each.value.username
  home_directory_type = "LOGICAL"

  home_directory_mappings {
    entry  = "/"
    target = each.value.is_admin == true ? "/${var.s3_bucket_name}" : "/${var.s3_bucket_name}/$${Transfer:UserName}"
  }

  lifecycle {
    ignore_changes = [
      home_directory_mappings
    ]
  }

}

resource "aws_transfer_ssh_key" "default" {
  for_each   = { for user in var.sftp_users : user.username => user }
  server_id  = join("", aws_transfer_server.default[*].id)
  user_name  = each.value.username
  body       = each.value.ssh_public_key

  depends_on = [
    aws_transfer_user.default
  ]
}