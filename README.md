# terraform-aws-template

[![Lint Status](https://github.com/DNXLabs/terraform-aws-template/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-template/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-template)](https://github.com/DNXLabs/terraform-aws-template/blob/master/LICENSE)

<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_name | The account or environment name | `string` | n/a | yes |
| address\_allocation\_ids | List of Elastic IPs Allocation IDs to attach to VPC Endpoint. | `list(string)` | n/a | yes |
| aws\_account\_id | AWS Account ID | `string` | n/a | yes |
| aws\_role | IAM Role | `string` | n/a | yes |
| domain\_host | The name of the Route 53 record | `string` | n/a | yes |
| domain\_zone | Hosted Zone name of the desired Hosted Zone | `string` | n/a | yes |
| endpoint\_type | PUBLIC or VPC | `string` | `"PUBLIC"` | no |
| ip\_allowlist | List of IPs to allow on WAF and IAM Policies | `any` | n/a | yes |
| public\_subnet\_ids | List of public subnet IDs for VPC Endpoint. | `list(any)` | `[]` | no |
| s3\_bucket\_name | The bucket name | `string` | n/a | yes |
| s3\_bucket\_versioning | Enable bucket versioning | `bool` | n/a | yes |
| security\_policy\_name | Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, and TransferSecurityPolicy-FIPS-2020-06. Default value is: TransferSecurityPolicy-2018-11. | `string` | `"TransferSecurityPolicy-2018-11"` | no |
| server\_name | Specifies the name of the SFTP server | `string` | n/a | yes |
| sftp\_users | List of SFTP usernames | `list(any)` | `[]` | no |
| vpc\_id | VPC ID to deploy the SFTP cluster. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | n/a |

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-template/blob/master/LICENSE) for full details.