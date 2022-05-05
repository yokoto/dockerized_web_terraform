# VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "example"
  }
}

# パブリックサブネット0
resource "aws_subnet" "public_0" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

# パブリックサブネット1
resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = true
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

# パブリックサブネット0と1のルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id
}

# パブリックサブネット0と1のルートテーブルへルートの追加
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.example.id
  destination_cidr_block = "0.0.0.0/0" # デフォルトルート（転送先が何も設定されていないときの、デフォルトの転送先）
}

# パブリックサブネット0とルートテーブルの関連付け
resource "aws_route_table_association" "public_0" {
  subnet_id = aws_subnet.public_0.id
  route_table_id = aws_route_table.public.id
}

# パブリックサブネット1とルートテーブルの関連付け
resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# プライベートサブネット0
resource "aws_subnet" "private_0" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.65.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false
}

# プライベートサブネット1
resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.66.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = false
}

# プライベートサブネット0のEIP
resource "aws_eip" "nat_gateway_0" {
  vpc = true
  depends_on = [aws_internet_gateway.example] # インターネットゲートウェイ作成後に、EIPを作成するよう保障
}

# プライベートサブネット1のEIP
resource "aws_eip" "nat_gateway_1" {
  vpc = true
  depends_on = [aws_internet_gateway.example]
}

# プライベートサブネット0のNATゲートウェイ
resource "aws_nat_gateway" "nat_gateway_0" {
  allocation_id = aws_eip.nat_gateway_0.id
  subnet_id = aws_subnet.public_0.id
  depends_on = [aws_internet_gateway.example] # インターネットゲートウェイ作成後に、NATゲートウェイを作成するよう保障
}

# プライベートサブネット1のNATゲートウェイ
resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id = aws_subnet.public_1.id
  depends_on = [aws_internet_gateway.example]
}

# プライベートサブネット0のルートテーブル
resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.example.id
}

# プライベートサブネット1のルートテーブル
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.example.id
}

# プライベートサブネット0のルートテーブルへルートの追加
resource "aws_route" "private_0" {
  route_table_id = aws_route_table.private_0.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_0.id
  destination_cidr_block = "0.0.0.0/0" # デフォルトルートはひとつのルートテーブルにつき、ひとつしか定義できない
}

# プライベートサブネット1のルートテーブルへルートの追加
resource "aws_route" "private_1" {
  route_table_id = aws_route_table.private_1.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  destination_cidr_block = "0.0.0.0/0"
}

# プライベートサブネット0とルートテーブルの関連付け
resource "aws_route_table_association" "private_0" {
  subnet_id = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}

# プライベートサブネット1とルートテーブルの関連付け
resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}
