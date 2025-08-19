output "kms_key_arns" {
  description = "ARNs of created KMS keys"
  value       = { for svc, key in aws_kms_key.service_keys : svc => key.arn }
}

output "kms_key_ids" {
  description = "IDs of created KMS keys"
  value       = { for svc, key in aws_kms_key.service_keys : svc => key.key_id }
}
