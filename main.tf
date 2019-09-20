terraform {
  required_providers {
    aws = {
      version = ">= 2.33.0" # needed for ACM data source
    }
    random = {
      version = ">= 2.2.1" # needed for random_pet
  }
}

# random bucket name - we don't know/care what this is, just need it to exist
resource "random_pet" "bucket" {}

# avoid matching any real files - add a policy to prevent anything being put in the bucket
data "aws_iam_policy_document" "keep_bucket_empty" {
  statement {
    sid    = "KeepBucketEmpty"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${random_pet.bucket.id}/*"]
  }
}

resource "aws_s3_bucket" "redirect" {

  # don't let anyone know about this bucket
  acl    = "private"
  # named after our random pet, but doesn't matter because it only exists to redirect other stuff
  bucket = random_pet.bucket.id

  policy = data.aws_iam_policy_document.keep_bucket_empty.json

  website {
    redirect_all_requests_to = "https://${var.destination_domain}"
  }
}

resource "aws_cloudfront_distribution" "redirect" {
  aliases = [var.source_domain]
  enabled = true

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 3600
    max_ttl                = 2592000 # 30 days
    min_ttl                = 0
    target_origin_id       = var.source_domain
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    domain_name = aws_s3_bucket.redirect.website_endpoint
    origin_id   = var.source_domain
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }
}
