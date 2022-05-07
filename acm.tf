# SSL証明書
resource "aws_acm_certificate" "example" {
  domain_name = aws_route53_record.example.name
  subject_alternative_names = []
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# SSLS証明書の検証用DNSレコード
resource "aws_route53_record" "example_certificate" {
  name = aws_acm_certificate.example.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.example.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.example.domain_validation_options[0].resource_record_value]
  zone_id = data.aws_route53_zone.example.id
  ttl = 60
}

# SSL証明書の検証完了まで待機
resource "aws_acm_certificate_validation" "example" {
  certificate_arn = aws_acm_certificate.example.arn
  validation_record_fqdns = [aws_route53_record.example_certificate.fqdn]
}
