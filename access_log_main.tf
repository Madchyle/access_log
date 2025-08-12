provider "aws" {
  region = "us-east-1" 
}

resource "aws_s3_bucket" "access_logs" {
  bucket = "aws-access-logs-bucket-12345" 
}

resource "aws_s3_bucket_acl" "access_logs_acl" {
  bucket = aws_s3_bucket.access_logs.id
  acl    = "log-delivery-write"
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
      days          = 30
      storage_class = "GLACIER" 
    }

    expiration {
      days = 365 
    }
    
    filter {
      prefix = ""
    }
  }
}
