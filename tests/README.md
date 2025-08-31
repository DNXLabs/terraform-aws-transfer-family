# AWS Transfer Family Terraform Module Tests

This directory contains comprehensive tests for the AWS Transfer Family Terraform module using Terraform's native testing framework.

## Test Structure

The tests are organized in `test.tftest.hcl` and cover various scenarios and configurations of the Transfer Family module.

## Test Coverage

### 1. Basic PUBLIC Endpoint Configuration (`test_public_endpoint_basic`)
- **Purpose**: Tests the basic setup with a PUBLIC endpoint
- **Key Validations**:
  - Transfer server configuration (SERVICE_MANAGED, SFTP protocol, PUBLIC endpoint)
  - S3 bucket encryption (AES256)
  - Single user creation with LOGICAL home directory
  - SSH key generation
  - IAM role creation for S3 access
  - Route53 CNAME record creation

### 2. VPC Endpoint Configuration (`test_vpc_endpoint_configuration`)
- **Purpose**: Tests VPC endpoint setup with security groups
- **Key Validations**:
  - VPC endpoint configuration with endpoint_details
  - Security group creation and rules (ingress on port 22, egress)
  - Multiple users (2 users)
  - S3 bucket versioning disabled

### 3. Multiple Users (`test_multiple_users`)
- **Purpose**: Tests scaling with multiple SFTP users
- **Key Validations**:
  - Creation of 3 users, SSH keys, IAM roles, and policies
  - TLS private key generation for each user
  - SSM parameter creation (public and private keys for each user)

### 4. Security Policy Configuration (`test_security_policy`)
- **Purpose**: Tests custom security policy application
- **Key Validations**:
  - Custom security policy (TransferSecurityPolicy-2020-06) application

### 5. Empty Users List (`test_empty_users_list`)
- **Purpose**: Tests module behavior with no users
- **Key Validations**:
  - No user-specific resources created
  - Transfer server still created
  - S3 bucket versioning set to "Suspended"

### 6. Output Validation (`test_outputs`)
- **Purpose**: Tests module outputs
- **Key Validations**:
  - Endpoint output is not null

### 7. Variable Validation (`test_invalid_s3_bucket_versioning`)
- **Purpose**: Tests input validation for s3_bucket_versioning
- **Key Validations**:
  - Expects failure when invalid versioning value is provided
  - Tests the validation rule that only allows "Enabled", "Disabled", or "Suspended"

## Mock Provider Configuration

The tests use mock AWS provider data to simulate:
- AWS caller identity (account ID, ARN, user ID)
- AWS region (us-east-1)
- Route53 hosted zone
- S3 bucket data

## Variable Validation

The module includes validation for the `s3_bucket_versioning` variable:
- **Allowed values**: "Enabled", "Disabled", "Suspended"
- **Default value**: "Enabled"
- **Validation**: Uses `contains()` function to ensure only valid values are accepted

## Running the Tests

To run these tests, use the following Terraform commands:

```bash
# Initialize the module
terraform init

# Run all tests
terraform test

# Run a specific test
terraform test -filter="test_public_endpoint_basic"
```

## Test Scenarios Covered

| Scenario | Endpoint Type | Users | Versioning | Security Policy | Notes |
|----------|---------------|-------|------------|-----------------|-------|
| Basic PUBLIC | PUBLIC | 1 | Enabled | Default | Basic functionality |
| VPC Endpoint | VPC | 2 | Disabled | Default | VPC with security groups |
| Multiple Users | PUBLIC | 3 | Enabled | Default | Scaling test |
| Security Policy | PUBLIC | 1 | Enabled | Custom | Policy customization |
| Empty Users | PUBLIC | 0 | Suspended | Default | Edge case |
| Output Test | PUBLIC | 1 | Enabled | Default | Output validation |
| Invalid Input | PUBLIC | 1 | Invalid | Default | Input validation |

## Resources Tested

The tests validate the creation and configuration of:

- **AWS Transfer Server**: Identity provider, protocols, endpoint type, security policy
- **AWS Transfer Users**: Home directory type, user creation based on input list
- **AWS Transfer SSH Keys**: Key generation and association with users
- **AWS S3 Bucket**: Encryption configuration, versioning settings
- **AWS IAM Roles and Policies**: S3 access permissions, logging permissions
- **AWS Security Groups**: VPC endpoint security (when applicable)
- **AWS Route53 Records**: CNAME record creation for custom domains
- **TLS Private Keys**: SSH key pair generation
- **AWS SSM Parameters**: Secure storage of SSH keys

## Best Practices Demonstrated

1. **Comprehensive Coverage**: Tests cover both happy path and edge cases
2. **Mock Data**: Uses mock provider to avoid actual AWS resource creation
3. **Variable Validation**: Tests input validation rules
4. **Resource Scaling**: Tests behavior with different numbers of users
5. **Configuration Variants**: Tests different endpoint types and configurations
6. **Error Handling**: Tests expected failures for invalid inputs
