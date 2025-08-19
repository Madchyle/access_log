locals {
  enabled_services = {
    for svc, enabled in {
      s3  = var.kms_services.s3
      ebs = var.kms_services.ebs
      sns = var.kms_services.sns
      rds = var.kms_services.rds
      sqs = var.kms_services.sqs
    } : svc => enabled if enabled
  }
}
