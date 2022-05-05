######
# 利用例:
# moudle "example_sg" {
#   source = "./security_group"
#   name = "module-sg"
#   vpc_id = aws_vpc.example.id
#   port = 80
#   cidr_blocks = ["0.0.0.0/0"]
# }
######
variable "name" {}
variable "vpc_id" {}
variable "port" {}
variable "cidr_blocks" {
  type = list(string)
}

resource "aws_security_group" "default" {
  name = var.name # セキュリティグループの名前
  vpc_id = var.vpc_id # VPCのID
}

# セキュリティグループルール（インバウンド）
resource "aws_security_group_rule" "ingress" {
  type = "ingress"
  from_port = var.port # 通信を許可するポート番号
  to_port = var.port
  protocol = "tcp"
  cidr_blocks = var.cidr_blocks # # 通信を許可するCIDRブロック
  security_group_id = aws_security_group.default.id
}

# セキュリティグループルール（アウトバウンド）
resource "aws_security_group_rule" "egresse" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

output "security_group_id" {
  value = aws_security_group.default.id
}
