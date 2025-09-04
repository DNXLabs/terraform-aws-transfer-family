# Create Elastic IPs for the Transfer Server
resource "aws_eip" "transfer_server" {
  count  = var.endpoint_type == "VPC" ? length(var.public_subnet_ids) : 0
  domain = "vpc"

  tags = {
    Name = "${var.server_name}-eip-${count.index + 1}"
  }
}

resource "aws_transfer_server" "default" {
  identity_provider_type = "SERVICE_MANAGED"
  protocols              = ["SFTP"]
  endpoint_type          = var.endpoint_type
  force_destroy          = true
  security_policy_name   = var.security_policy_name
  logging_role           = join("", aws_iam_role.logging[*].arn)

  dynamic "endpoint_details" {
    for_each = var.endpoint_type == "VPC" ? [1] : []
    content {
      address_allocation_ids = aws_eip.transfer_server[*].allocation_id
      subnet_ids             = var.public_subnet_ids
      vpc_id                 = var.vpc_id
      security_group_ids     = [aws_security_group.sftp_sg[0].id]
    }
  }

  tags = {
    Name = var.server_name
  }
}

resource "aws_transfer_user" "default" {
  for_each            = { for user in var.sftp_users : user.username => user }
  server_id           = join("", aws_transfer_server.default[*].id)
  role                = aws_iam_role.s3_access_for_sftp_users[each.value.username].arn
  user_name           = each.value.username
  home_directory_type = "LOGICAL"

  home_directory_mappings {
    entry  = "/"
    target = "/${aws_s3_bucket.sftp.bucket}/$${Transfer:UserName}"
  }

  lifecycle {
    ignore_changes = [
      home_directory_mappings
    ]
  }

}

resource "aws_transfer_ssh_key" "default" {
  for_each  = { for user in var.sftp_users : user.username => user }
  server_id = join("", aws_transfer_server.default[*].id)
  user_name = each.value.username
  body      = tls_private_key.sftp_ssh_key[each.value.username].public_key_openssh

  depends_on = [
    aws_transfer_user.default
  ]
}

resource "aws_security_group" "sftp_sg" {
  count       = var.endpoint_type == "VPC" ? 1 : 0
  name        = "sftp-${var.server_name}-sg"
  description = "SG for SFTP Server"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ftp-${var.server_name}-sg"
  }
}

resource "aws_security_group_rule" "ip_allowlist" {
  count             = var.endpoint_type == "VPC" ? 1 : 0
  description       = "IP Allow List"
  type              = "ingress"
  protocol          = "TCP"
  to_port           = 22
  from_port         = 22
  cidr_blocks       = var.allowed_ips_list
  security_group_id = aws_security_group.sftp_sg[0].id
}

resource "aws_security_group_rule" "egress" {
  count             = var.endpoint_type == "VPC" ? 1 : 0
  description       = "Traffic to internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sftp_sg[0].id
  cidr_blocks       = ["0.0.0.0/0"]
}
