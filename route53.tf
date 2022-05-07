# ホストゾーンのデータソース定義
# Route 53でドメインを登録した場合はホストゾーン、NSレコード、SOAレコードが自動的に作成されるため、以下のように参照できる
# data "aws_route53_zone" "example" {
#   name = "exapmle.com"
# }

# ホストゾーンのリソース定義
# 新規にホストゾーンを作成する場合
resource "aws_route53_zone" "test_example" {
  name = "test.example.com"
}

# ALBのDNSレコード
resource "aws_route53_record" "example" {
  zone_id = aws_route53_zone.test_example.zone_id
  name = aws_route53_zone.test_example.name
  type = "A" # ALIASレコード

  alias {
    name = aws_lb.example.dns_name
    zone_id = aws_lb.example.zone_id
    evaluate_target_health = true
  }
}

output "domain_name" {
  value = aws_route53_record.example.name
}
