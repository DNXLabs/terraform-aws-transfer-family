variable "s3_bucket_name" {
  type = string
  description = "The bucket name"
}

variable "server_name" {
  type = string
  description = "Specifies the name of the SFTP server"
}

variable "security_policy_name" {
  type        = string
  description = "Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, and TransferSecurityPolicy-FIPS-2020-06. Default value is: TransferSecurityPolicy-2018-11."
  default     = "TransferSecurityPolicy-2018-11"
}

variable "sftp_users" {
  type = list(object({
    username  = string,
    ssh_public_key = string
    is_admin = bool
  }))

  default     = []
  description = "List of SFTP usernames and public keys"
}