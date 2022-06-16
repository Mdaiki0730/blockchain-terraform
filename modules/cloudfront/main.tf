// cloudfront
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.hosted.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.hosted.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_www.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"
  aliases             = [var.frontend_domain]

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.hosted.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

resource "aws_cloudfront_origin_access_identity" "static_www" {}

// s3
resource "aws_s3_bucket" "hosted" {
  bucket = var.hosted_bucket_name
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.hosted.id
  policy = data.aws_iam_policy_document.s3_site_policy.json
}

resource "aws_s3_bucket_acl" "b_acl" {
  bucket = aws_s3_bucket.hosted.id
  acl    = "private"
}

data "aws_iam_policy_document" "s3_site_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.hosted.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.static_www.iam_arn]
    }
  }
}

// route53
resource "aws_route53_record" "cloudfront" {
  zone_id = var.zone_id
  name    = var.frontend_domain
  type    = "CNAME"
  ttl     = 300
  records = [aws_cloudfront_distribution.s3_distribution.domain_name]
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"

  zone_id = var.zone_id
}

resource "aws_acm_certificate" "cert" {
  provider                  = aws.virginia
  domain_name               = "*.${var.domain}"
  subject_alternative_names = ["${var.domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.prefix}-acm"
  }
}
