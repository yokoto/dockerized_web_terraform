######
# 利用例
# module "describe_regions_for_ec2" {
#   source = "./iam_role"
#   name = "describe-regions-for-ec2"
#   identifier = "ec2.amazonaws.com"
#   policy = data.aws_iam_policy_document.allow_describe_regions.json
# }
######
variable "name" {}
variable "policy" {}
variable "identifier" {}

# IAMロール
resource "aws_iam_role" "default" {
  name = var.name # IAMロールの名前
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# 信頼ポリシー
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"] # AWSリソースにアクセスできる一時的なクレデンシャル取得権限の付与
  }

  principals {
    type = "Service"
    identifiers =  [var.identifier] # IAMロールを関連付けるAWSのサービス識別子
  }
}

# IAMポリシー
resource "aws_iam_policy" "default" {
  name = var.name # IAMポリシーの名前
  policy = var.policy # ポリシードキュメント
}

# IAMロールへのIAMポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "default" {
  role = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

output "iam_role_arn" {
  value = aws_iam_role.default.arn
}

output "iam_role_name" {
  value = aws_iam_role.default.name
}