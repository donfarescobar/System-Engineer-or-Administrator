# VPC berisi subnet per zona. Zona berlabel mengikuti network-architecture.md
# paragraf 2. Zona "core" tidak dibuat di cloud karena core banking on-premise
# (ADR-01); ketiadaan rute ke core di sisi cloud justru memenuhi aturan deny
# nomor 5 dan 7 pada tabel firewall.

data "aws_caller_identity" "current" {}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = var.vpc_name
    layer = "vpc"
  }
}

resource "aws_subnet" "zone" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = var.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-${each.key}-subnet"
    zone = each.key
  }
}

# DMZ berisi WAF / reverse proxy yang bersifat publik. Public IP tidak
# di-auto-assign ke instance pada subnet; public endpoint hanya dilekatkan ke
# load balancer internet-facing pada tier DMZ (lihat module zone-security).
# Zona lain sepenuhnya privat.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route_table" "dmz" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name_prefix}-dmz-rt"
  }
}

resource "aws_route" "dmz_default" {
  route_table_id         = aws_route_table.dmz.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "dmz" {
  subnet_id      = aws_subnet.zone["dmz"].id
  route_table_id = aws_route_table.dmz.id
}

# Private zone (app/middleware/mgmt) tidak punya rute default ke internet.
# Egress keluar sistem (mis. proxy patch, update) ditempatkan sebagai jalur
# khusus di zona mgmt, konsisten dengan prinsip deny outbound dari zona tengah.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name_prefix}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = {
    for zone, cidr in var.subnets : zone => cidr
    if zone != "dmz"
  }

  subnet_id      = aws_subnet.zone[each.key].id
  route_table_id = aws_route_table.private.id
}

# Default security group VPC tidak boleh membiarkan seluruh traffic (kontrol
# default-deny). Kosongkan aturannya; resource ini akan menghapus rule bawaan.
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-default-sg"
    zone = "default"
  }
}

# VPC Flow Logging untuk deteksi anomali volumetrik (padanan NetFlow/sFlow di
# cloud). Retensi 365 hari agar cukup untuk investigasi insiden keamanan &
# korelasi audit, terenkripsi KMS.
resource "aws_kms_key" "flow_logs" {
  description             = "Enkripsi at-rest VPC flow logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "RootAccess"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudWatchLogs"
        Effect    = "Allow"
        Principal = { Service = "logs.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-kms-vpcflow"
  }
}

resource "aws_kms_alias" "flow_logs" {
  name          = "alias/${var.name_prefix}-vpcflow"
  target_key_id = aws_kms_key.flow_logs.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc-flow-logs/${var.name_prefix}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.flow_logs.arn

  tags = {
    Name = "${var.name_prefix}-cw-vpcflow"
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.name_prefix}-vpc-flowlog-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "vpc-flow-logs.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.name_prefix}-vpc-flowlog-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          aws_cloudwatch_log_group.vpc_flow_logs.arn,
          "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
        ]
      }
    ]
  })
}

resource "aws_flow_log" "vpc" {
  vpc_id                   = aws_vpc.this.id
  iam_role_arn             = aws_iam_role.vpc_flow_logs.arn
  log_destination          = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type     = "cloud-watch-logs"
  traffic_type             = "ALL"
  max_aggregation_interval = 60

  tags = {
    Name = "${var.name_prefix}-vpc-flowlog"
  }
}