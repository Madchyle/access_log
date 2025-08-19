resource "aws_kms_key" "service_keys" {
  for_each = local.enabled_services

  description             = "CMK for ${each.key} encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = {
    Name    = "${var.prefix}-${each.key}-kms"
    Service = each.key
  }
}

