resource "aws_kms_key" "service_keys" {
  for_each = local.enabled_services

  description             = "CMK for ${each.key} encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = {
    Name    = "${var.kms_services.prefix}-${each.key}-kms"
    Service = each.key
  }
}

output "kms_key_arns" {
  description = "ARNs of created KMS keys"
  value       = { for svc, key in aws_kms_key.service_keys : svc => key.arn }
}

output "kms_key_ids" {
  description = "IDs of created KMS keys"
  value       = { for svc, key in aws_kms_key.service_keys : svc => key.key_id }
}
