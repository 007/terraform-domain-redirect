output "cloudfront_domain" {
  value = aws_cloudfront_distribution.redirect.domain_name
}
