resource "aws_iam_policy" "logging" {
  name   = "transfer-family-logging-${var.server_name}"
  policy = data.aws_iam_policy_document.logging.json
}

resource "aws_iam_role" "logging" {
  name                = "transfer-family-logging-${var.server_name}"
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.logging.arn]
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_access_for_sftp_users" {
  for_each = { for user in var.sftp_users : user.username => user }

  statement {
    sid       = "AllowListingOfUserFolder"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [join("", data.aws_s3_bucket.landing[*].arn)]
  }

  statement {
    sid    = "HomeDirObjectAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObjectVersion",
      "s3:GetObjectACL",
      "s3:PutObjectACL"
    ]
    resources = ["${join("", data.aws_s3_bucket.landing[*].arn)}/${each.value.username}/*"]
  }
}

data "aws_iam_policy_document" "logging" {
  statement {
    sid    = "CloudWatchAccessForAWSTransfer"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "s3_access_for_sftp_users" {
  for_each = { for user in var.sftp_users : user.username => user }
  name     = "${each.value.username}-s3-access-for-sftp"
  policy   = data.aws_iam_policy_document.s3_access_for_sftp_users[each.value.username].json
}

resource "aws_iam_role" "s3_access_for_sftp_users" {
  for_each            = { for user in var.sftp_users : user.username => user }
  name                = "${each.value.username}-s3-access-for-sftp"
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.s3_access_for_sftp_users[each.value.username].arn]
}
