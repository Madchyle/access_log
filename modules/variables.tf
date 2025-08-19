variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "kms_services" {
  description = "Enable or disable KMS CMKs for each service"
  type = object({
    s3     = bool
    ebs    = bool
    sns    = bool
    rds    = bool
    sqs    = bool
    prefix = string
  })

  default = {
    s3     = true
    ebs    = true
    sns    = true
    rds    = true
    sqs    = true
    prefix = "myproject"
  }
}
