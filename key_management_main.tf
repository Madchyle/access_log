variable "kms_services" {
  description = "Enable or disable KMS CMKs"
  type = object({
    s3   = bool
    ebs  = bool
    sns  = bool
    rds  = bool
    sqs  = bool
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

resource "aws_kms_key" "service_keys" {
  for_each = {
    for svc, enabled in {
      s3  = var.kms_services.s3
      ebs = var.kms_services.ebs
      sns = var.kms_services.sns
      rds = var.kms_services.rds
      sqs = var.kms_services.sqs
    } : svc => enabled if enabled
  }

  description         = "CMK for ${each.key} encryption"
  enable_key_rotation = true
  deletion_window_in_days = 30

  tags = {
    Name   = "${var.kms_services.prefix}-${each.key}-kms"
    Service = each.key
  }
}

output "kms_key_arns" {
  value = { for svc, key in aws_kms_key.service_keys : svc => key.arn }
}

output "kms_key_ids" {
  value = { for svc, key in aws_kms_key.service_keys : svc => key.key_id }
}
