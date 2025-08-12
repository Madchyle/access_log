variable "kms" {
type = map 
default = {
s3 = true
ebs = true
sns = true
rds = true
sqs = true
}
}

resource "aws_kms_key" "service_keys" {
  for_each            = { for svc, enabled in var.kms : svc => enabled if enabled }
  description         = "CMK for ${each.key} encryption"
  enable_key_rotation = true
}

