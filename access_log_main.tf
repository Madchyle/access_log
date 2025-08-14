variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "S3 bucket name"
  type        = string
  default     = "aws-access-logs"
}

variable "transition_days" {
  description = "Days before logs transition to Glacier"
  type        = number
  default     = 30
}

variable "expiration_days" {
  description = "Days before logs are deleted"
  type        = number
  default     = 365
}

locals {
  log_delivery_accounts = {
    "us-east-1"      = "127311923021"
    "us-east-2"      = "033677994240"
    "us-west-1"      = "173754725891"
    "us-west-2"      = "234567890123"
    "eu-west-1"      = "156460612806"
    "eu-west-2"      = "652711504416"
    "eu-central-1"   = "054676820928"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "access_logs" {
  bucket = "${var.bucket_prefix}-${var.aws_region}-${random_id.bucket_suffix.hex}"

  tags = {
    prevent-recursion = "true"
  }
}

resource "aws_s3_bucket_versioning" "access_logs_versioning" {
  bucket = aws_s3_bucket.access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "access_logs_acl" {
  bucket = aws_s3_bucket.access_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_policy" "access_logs_policy" {
  bucket = aws_s3_bucket.access_logs.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ServerAccessLogsPolicy",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.log_delivery_accounts[var.aws_region]}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.access_logs.arn}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "access_logs_block" {
  bucket                  = aws_s3_bucket.access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs_lifecycle" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    id     = "log-archive"
    status = "Enabled"

    transition {
      days          = var.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.expiration_days
    }

    filter {
      prefix = ""
    }
  }
}
