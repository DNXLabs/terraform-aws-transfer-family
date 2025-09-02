variable "s3_bucket_name" {
  type        = string
  description = "The bucket name"
}

variable "s3_bucket_versioning" {
  type        = string
  default     = "Enabled"
  description = "S3 bucket versioning configuration. 'Enabled' - versioning is active and new object versions are created; 'Disabled' - versioning is turned off for new objects (existing versions remain); 'Suspended' - versioning is paused, new objects overwrite existing ones but previous versions are preserved"

  validation {
    condition     = contains(["Enabled", "Disabled", "Suspended"], var.s3_bucket_versioning)
    error_message = "The s3_bucket_versioning value must be one of: 'Enabled', 'Disabled', or 'Suspended'."
  }
}

variable "server_name" {
  type        = string
  description = "Specifies the name of the SFTP server"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy the SFTP cluster."
}

variable "security_policy_name" {
  type        = string
  description = "Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, and TransferSecurityPolicy-FIPS-2020-06. Default value is: TransferSecurityPolicy-2018-11."
  default     = "TransferSecurityPolicy-2018-11"
}

variable "sftp_users" {
  type = list(object({
    username = string
  }))
  default     = []
  description = "List of SFTP usernames"
}


variable "allowed_ips_list" {
  type        = list(string)
  description = "List of IPs to allow on WAF and IAM Policies. Each IP must be in CIDR format (e.g., '192.168.1.0/24' or '10.0.0.1/32')"
  
  validation {
    condition = alltrue([
      for ip in var.allowed_ips_list : can(cidrhost(ip, 0))
    ])
    error_message = "All IP addresses in allowed_ips_list must be in valid CIDR format (e.g., '192.168.1.0/24' or '10.0.0.1/32')."
  }
}

variable "endpoint_type" {
  default     = "PUBLIC"
  description = "PUBLIC or VPC"
  type        = string
}

variable "public_subnet_ids" {
  type        = list(any)
  default     = []
  description = "List of public subnet IDs for VPC Endpoint."
}
variable "domain_zone" {
  type        = string
  default     = ""
  description = "(optional) Hosted Zone name of the desired Hosted Zone"
}

variable "domain_host" {
  type        = string
  default     = ""
  description = "(optional) The name of the Route 53 record"
}

variable "account_name" {
  type        = string
  description = "The account or environment name"
}
