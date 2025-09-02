# terraform-aws-template

[![Lint Status](https://github.com/DNXLabs/terraform-aws-template/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-template/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-template)](https://github.com/DNXLabs/terraform-aws-template/blob/master/LICENSE)

<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.0.0 |
| tls | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0.0 |
| tls | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_name | The account or environment name | `string` | n/a | yes |
| allowed\_ips\_list | List of IPs to allow on WAF and IAM Policies. Each IP must be in CIDR format (e.g., '192.168.1.0/24' or '10.0.0.1/32') | `list(string)` | n/a | yes |
| domain\_host | (optional) The name of the Route 53 record | `string` | `""` | no |
| domain\_zone | (optional) Hosted Zone name of the desired Hosted Zone | `string` | `""` | no |
| endpoint\_type | PUBLIC or VPC | `string` | `"PUBLIC"` | no |
| public\_subnet\_ids | List of public subnet IDs for VPC Endpoint. | `list(any)` | `[]` | no |
| s3\_bucket\_name | The bucket name | `string` | n/a | yes |
| s3\_bucket\_versioning | S3 bucket versioning configuration. 'Enabled' - versioning is active and new object versions are created; 'Disabled' - versioning is turned off for new objects (existing versions remain); 'Suspended' - versioning is paused, new objects overwrite existing ones but previous versions are preserved | `string` | `"Enabled"` | no |
| security\_policy\_name | Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, and TransferSecurityPolicy-FIPS-2020-06. Default value is: TransferSecurityPolicy-2018-11. | `string` | `"TransferSecurityPolicy-2018-11"` | no |
| server\_name | Specifies the name of the SFTP server | `string` | n/a | yes |
| sftp\_users | List of SFTP usernames | <pre>list(object({<br>    username = string<br>  }))</pre> | `[]` | no |
| vpc\_id | VPC ID to deploy the SFTP cluster. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| eip\_allocation\_ids | List of Elastic IP allocation IDs created for the Transfer Server |
| eip\_public\_ips | List of Elastic IP public IPs created for the Transfer Server |
| endpoint | n/a |

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-template/blob/master/LICENSE) for full details.