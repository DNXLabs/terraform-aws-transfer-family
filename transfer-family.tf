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
      address_allocation_ids = var.address_allocation_ids
      subnet_ids             = var.public_subnet_ids
      vpc_id                 = var.vpc_id
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
    target = "/${var.s3_bucket_name}/$${Transfer:UserName}"
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
  name        = "sftp-${var.server_name}-sg"
  description = "SG for SFTP Server"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ftp-${var.server_name}-sg"
  }
}

resource "aws_security_group_rule" "ip_allowlist" {
  description       = "IP Allow List"
  type              = "ingress"
  protocol          = "TCP"
  to_port           = 22
  from_port         = 22
  cidr_blocks       = split(",", var.ip_allowlist)
  security_group_id = aws_security_group.sftp_sg.id
}

resource "aws_security_group_rule" "egress" {
  description       = "Traffic to internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sftp_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "null_resource" "update-vpc-endpoint-security-group" {

  count = var.endpoint_type == "VPC" ? 1 : 0

  triggers = {
    aws_transfer_server_id = aws_transfer_server.default.id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
set -e

CREDENTIALS=(`aws sts assume-role \
  --role-arn arn:aws:iam::${var.aws_account_id}:role/${var.aws_role} \
  --role-session-name "update-vpc-endpoint-security-group" \
  --query "[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]" \
  --region ap-southeast-2 \
  --output text`)

unset AWS_PROFILE
export AWS_DEFAULT_REGION=ap-southeast-2
export AWS_ACCESS_KEY_ID=$${CREDENTIALS[0]}
export AWS_SECRET_ACCESS_KEY=$${CREDENTIALS[1]}
export AWS_SESSION_TOKEN=$${CREDENTIALS[2]}
export AWS_SECURITY_TOKEN=$${CREDENTIALS[2]}

echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
echo $AWS_SESSION_TOKEN
echo $AWS_SECURITY_TOKEN

aws ec2 modify-vpc-endpoint --vpc-endpoint-id ${join("", aws_transfer_server.default.endpoint_details.*.vpc_endpoint_id)} --add-security-group-ids '${aws_security_group.sftp_sg.id}' --region ${data.aws_region.current.name}
EOF
  }
}
