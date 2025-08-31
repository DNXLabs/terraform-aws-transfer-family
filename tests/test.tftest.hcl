# Test configuration for AWS Transfer Family module

# Mock provider for testing
mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:root"
      user_id    = "123456789012"
    }
  }

  mock_data "aws_region" {
    defaults = {
      name = "us-east-1"
    }
  }

  mock_data "aws_route53_zone" {
    defaults = {
      zone_id = "Z123456789"
      name    = "example.com"
    }
  }

  mock_data "aws_s3_bucket" {
    defaults = {
      id     = "test-sftp-bucket-12345"
      arn    = "arn:aws:s3:::test-sftp-bucket-12345"
      bucket = "test-sftp-bucket-12345"
    }
  }

  # Override IAM policy documents to provide valid JSON
  override_data {
    target = data.aws_iam_policy_document.assume_role_policy
    values = {
      json = "{}"
    }
  }

  override_data {
    target = data.aws_iam_policy_document.logging
    values = {
      json = "{}"
    }
  }

  # Override S3 access policy documents for SFTP users (for_each data source)
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

# Test 1: Basic PUBLIC endpoint configuration
run "test_public_endpoint_basic" {
  command = plan

  variables {
    s3_bucket_name       = "test-sftp-bucket"
    s3_bucket_versioning = "Enabled"
    server_name          = "test-sftp-server"
    vpc_id               = "vpc-12345678"
    sftp_users = [
      {
        username = "testuser1"
      }
    ]
    allowed_ips_list      = ["10.0.0.0/8", "192.168.1.0/24"]
    endpoint_type         = "PUBLIC"
    public_subnet_ids     = ["subnet-12345678"]
    domain_zone           = "example.com"
    domain_host           = "sftp.example.com"
    account_name          = "test-account"
  }

  # Verify Transfer Server is created with correct configuration
  assert {
    condition     = aws_transfer_server.default.identity_provider_type == "SERVICE_MANAGED"
    error_message = "Transfer server should use SERVICE_MANAGED identity provider"
  }

  assert {
    condition     = contains(aws_transfer_server.default.protocols, "SFTP")
    error_message = "Transfer server should support SFTP protocol"
  }

  assert {
    condition     = aws_transfer_server.default.endpoint_type == "PUBLIC"
    error_message = "Transfer server should have PUBLIC endpoint type"
  }

  assert {
    condition     = aws_transfer_server.default.force_destroy == true
    error_message = "Transfer server should have force_destroy enabled"
  }

  # Verify S3 bucket encryption is created
  assert {
    condition     = length(aws_s3_bucket_server_side_encryption_configuration.sftp.rule) > 0
    error_message = "S3 bucket should have encryption configuration"
  }

  # Verify S3 bucket versioning is configured
  assert {
    condition     = aws_s3_bucket_versioning.sftp.versioning_configuration[0].status == "Enabled"
    error_message = "S3 bucket versioning should be enabled"
  }

  # Verify user is created
  assert {
    condition     = length(aws_transfer_user.default) == 1
    error_message = "Should create one transfer user"
  }

  assert {
    condition     = aws_transfer_user.default["testuser1"].home_directory_type == "LOGICAL"
    error_message = "Transfer user should have LOGICAL home directory type"
  }

  # Verify SSH key is created
  assert {
    condition     = length(aws_transfer_ssh_key.default) == 1
    error_message = "Should create one SSH key for the user"
  }

  # Verify IAM roles are created
  assert {
    condition     = length(aws_iam_role.s3_access_for_sftp_users) == 1
    error_message = "Should create IAM role for S3 access"
  }

  # Verify Route53 record is created
  assert {
    condition     = aws_route53_record.transfer-family.type == "CNAME"
    error_message = "Route53 record should be of type CNAME"
  }

  assert {
    condition     = aws_route53_record.transfer-family.ttl == 300
    error_message = "Route53 record should have TTL of 300"
  }
}

# Test 2: VPC endpoint configuration
run "test_vpc_endpoint_configuration" {
  command = plan

  variables {
    s3_bucket_name       = "test-sftp-bucket"
    s3_bucket_versioning = "Disabled"
    server_name          = "test-sftp-server-vpc"
    vpc_id               = "vpc-87654321"
    sftp_users = [
      {
        username = "vpcuser1"
      },
      {
        username = "vpcuser2"
      }
    ]
    allowed_ips_list      = ["172.16.0.0/12"]
    endpoint_type         = "VPC"
    public_subnet_ids     = ["subnet-87654321", "subnet-12345678"]
    domain_zone           = "example.com"
    domain_host           = "sftp-vpc.example.com"
    account_name          = "test-account"
  }

  # Verify VPC endpoint configuration
  assert {
    condition     = aws_transfer_server.default.endpoint_type == "VPC"
    error_message = "Transfer server should have VPC endpoint type"
  }

  assert {
    condition     = length(aws_transfer_server.default.endpoint_details) == 1
    error_message = "VPC endpoint should have endpoint_details configured"
  }

  # Verify security group is created for VPC endpoint
  assert {
    condition     = length(aws_security_group.sftp_sg) == 1
    error_message = "Should create security group for VPC endpoint"
  }

  assert {
    condition     = aws_security_group.sftp_sg[0].vpc_id == "vpc-87654321"
    error_message = "Security group should be in the correct VPC"
  }

  # Verify security group rules
  assert {
    condition     = length(aws_security_group_rule.ip_allowlist) == 1
    error_message = "Should create ingress rule for IP allowlist"
  }

  assert {
    condition     = aws_security_group_rule.ip_allowlist[0].from_port == 22
    error_message = "Ingress rule should allow port 22"
  }

  assert {
    condition     = aws_security_group_rule.ip_allowlist[0].to_port == 22
    error_message = "Ingress rule should allow port 22"
  }

  assert {
    condition     = length(aws_security_group_rule.egress) == 1
    error_message = "Should create egress rule"
  }

  # Verify multiple users are created
  assert {
    condition     = length(aws_transfer_user.default) == 2
    error_message = "Should create two transfer users"
  }

  # Verify multiple SSH keys are created
  assert {
    condition     = length(aws_transfer_ssh_key.default) == 2
    error_message = "Should create SSH keys for both users"
  }
}

# Test 3: Multiple users with different configurations
run "test_multiple_users" {
  command = plan

  variables {
    s3_bucket_name       = "multi-user-sftp-bucket"
    s3_bucket_versioning = "Enabled"
    server_name          = "multi-user-sftp-server"
    vpc_id               = "vpc-11111111"
    sftp_users = [
      {
        username = "user1"
      },
      {
        username = "user2"
      },
      {
        username = "user3"
      }
    ]
    allowed_ips_list      = ["10.0.0.0/8"]
    endpoint_type         = "PUBLIC"
    public_subnet_ids     = ["subnet-11111111"]
    domain_zone           = "example.com"
    domain_host           = "multi-sftp.example.com"
    account_name          = "test-account"
  }

  # Verify all users are created
  assert {
    condition     = length(aws_transfer_user.default) == 3
    error_message = "Should create three transfer users"
  }

  # Verify all SSH keys are created
  assert {
    condition     = length(aws_transfer_ssh_key.default) == 3
    error_message = "Should create three SSH keys"
  }

  # Verify all IAM roles are created
  assert {
    condition     = length(aws_iam_role.s3_access_for_sftp_users) == 3
    error_message = "Should create three IAM roles for S3 access"
  }

  # Verify all IAM policies are created
  assert {
    condition     = length(aws_iam_policy.s3_access_for_sftp_users) == 3
    error_message = "Should create three IAM policies for S3 access"
  }

  # Verify all TLS private keys are created
  assert {
    condition     = length(tls_private_key.sftp_ssh_key) == 3
    error_message = "Should create three TLS private keys"
  }

  # Verify all SSM parameters are created (2 per user: public and private keys)
  assert {
    condition     = length(aws_ssm_parameter.sftp_users_public_ssh_key) == 3
    error_message = "Should create three SSM parameters for public keys"
  }

  assert {
    condition     = length(aws_ssm_parameter.sftp_users_private_ssh_key) == 3
    error_message = "Should create three SSM parameters for private keys"
  }
}

# Test 4: Security policy configuration
run "test_security_policy" {
  command = plan

  variables {
    s3_bucket_name       = "secure-sftp-bucket"
    s3_bucket_versioning = "Enabled"
    server_name          = "secure-sftp-server"
    vpc_id               = "vpc-22222222"
    security_policy_name = "TransferSecurityPolicy-2020-06"
    sftp_users = [
      {
        username = "secureuser"
      }
    ]
    allowed_ips_list      = ["192.168.0.0/16"]
    endpoint_type         = "PUBLIC"
    public_subnet_ids     = ["subnet-22222222"]
    domain_zone           = "example.com"
    domain_host           = "secure-sftp.example.com"
    account_name          = "test-account"
  }

  # Verify security policy is applied
  assert {
    condition     = aws_transfer_server.default.security_policy_name == "TransferSecurityPolicy-2020-06"
    error_message = "Transfer server should use the specified security policy"
  }
}

# Test 5: Empty users list
run "test_empty_users_list" {
  command = plan

  variables {
    s3_bucket_name       = "empty-users-sftp-bucket"
    s3_bucket_versioning = "Suspended"
    server_name          = "empty-users-sftp-server"
    vpc_id               = "vpc-33333333"
    sftp_users           = []
    allowed_ips_list      = ["10.0.0.0/8"]
    endpoint_type         = "PUBLIC"
    public_subnet_ids     = ["subnet-33333333"]
    domain_zone           = "example.com"
    domain_host           = "empty-sftp.example.com"
    account_name          = "test-account"
  }

  # Verify no users are created
  assert {
    condition     = length(aws_transfer_user.default) == 0
    error_message = "Should not create any transfer users when list is empty"
  }

  # Verify no SSH keys are created
  assert {
    condition     = length(aws_transfer_ssh_key.default) == 0
    error_message = "Should not create any SSH keys when no users"
  }

  # Verify no user-specific IAM resources are created
  assert {
    condition     = length(aws_iam_role.s3_access_for_sftp_users) == 0
    error_message = "Should not create user IAM roles when no users"
  }

  # Verify server is still created
  assert {
    condition     = aws_transfer_server.default.identity_provider_type == "SERVICE_MANAGED"
    error_message = "Transfer server should still be created even with no users"
  }
}

# Test 6: Variable validation test for s3_bucket_versioning
run "test_invalid_s3_bucket_versioning" {
  command = plan

  variables {
    s3_bucket_name       = "invalid-versioning-bucket"
    s3_bucket_versioning = "InvalidValue"
    server_name          = "invalid-versioning-server"
    vpc_id               = "vpc-55555555"
    sftp_users = [
      {
        username = "testuser"
      }
    ]
    allowed_ips_list      = ["10.0.0.0/8"]
    endpoint_type         = "PUBLIC"
    public_subnet_ids     = ["subnet-55555555"]
    domain_zone           = "example.com"
    domain_host           = "invalid-sftp.example.com"
    account_name          = "test-account"
  }

  expect_failures = [
    var.s3_bucket_versioning,
  ]
}
