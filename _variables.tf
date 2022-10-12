variable "s3_bucket_name" {
  type        = string
  description = "The bucket name"
}

variable "s3_bucket_versioning" {
  type        = bool
  default     = true
  description = "Enable bucket versioning"
}

variable "server_name" {
  type        = string
  description = "Specifies the name of the SFTP server"
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