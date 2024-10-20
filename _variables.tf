variable "s3_bucket_name" {
  type        = string
  description = "The bucket name"
}

variable "s3_bucket_versioning" {
  type        = bool
  description = "Enable bucket versioning"
}

variable "server_name" {
  type        = string
  description = "Specifies the name of the SFTP server"
}

variable "vpc_id" {
  description = "VPC ID to deploy the SFTP cluster."
}

variable "security_policy_name" {
  type        = string
  description = "Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, and TransferSecurityPolicy-FIPS-2020-06. Default value is: TransferSecurityPolicy-2018-11."
  default     = "TransferSecurityPolicy-2018-11"
}

variable "sftp_users" {
  type        = list(any)
  default     = []
  description = "List of SFTP usernames"
}

variable "address_allocation_ids" {
  type        = list(string)
  description = "List of Elastic IPs Allocation IDs to attach to VPC Endpoint."
}

variable "ip_allowlist" {
  #type        = list(string)
  description = "List of IPs to allow on WAF and IAM Policies"
}

variable "endpoint_type" {
  default     = "PUBLIC"
  description = "PUBLIC or VPC"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "aws_role" {
  type        = string
  description = "IAM Role"
}

variable "public_subnet_ids" {
  type        = list(any)
  default     = []
  description = "List of public subnet IDs for VPC Endpoint."
}
variable "domain_zone" {
  type        = string
  description = "Hosted Zone name of the desired Hosted Zone"
}

variable "domain_host" {
  type        = string
  description = "The name of the Route 53 record"
}

variable "account_name" {
  type        = string
  description = "The account or environment name"
}