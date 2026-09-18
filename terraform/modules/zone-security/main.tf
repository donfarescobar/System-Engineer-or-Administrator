# Security group bersifat default-deny: tanpa rule ingress, traffic tidak akan
# pernah diizinkan masuk. Aturan yang dibuat di bawah adalah terjemahan tabel
# kebijakan firewall di network-architecture.md paragraf 5.
#
# Aturan deny tersurat di dokumen (No. 5: siapa pun ke Core; No. 7: Core ke
# internet) tidak memerlukan resource tersendiri pada tier cloud ini karena
# zona core tidak ada di sini dan tidak ada rute/rule yang mengizinkannya.

# ---------------------------------------------------------------------------
# DMZ (WAF / reverse proxy publik)
# fw #1: Internet -> DMZ 443
# ---------------------------------------------------------------------------
resource "aws_security_group" "dmz" {
  #checkov:skip=CKV2_AWS_5:Modul referensi jaringan murni (tanpa resource compute). Attachment SG ke EC2/ALB/ASG dibuat pada modul komputasi di implementasi lanjutan.
  name        = "${var.name_prefix}-dmz-sg"
  description = "WAF/reverse proxy publik - hanya 443 dari internet"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-dmz-sg"
    zone = "dmz"
  }
}

resource "aws_security_group_rule" "dmz_ingress_443" {
  security_group_id = aws_security_group.dmz.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "fw #1 - Internet ke DMZ 443"
}

resource "aws_security_group_rule" "dmz_egress_app" {
  security_group_id        = aws_security_group.dmz.id
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "fw #2 - DMZ ke App 443 (mTLS)"
}

# ---------------------------------------------------------------------------
# App (API gateway / digital channel)
# fw #2: DMZ -> App 443 (mTLS)
# fw #3: App -> Middleware 9093 (Kafka TLS)
# ---------------------------------------------------------------------------
resource "aws_security_group" "app" {
  #checkov:skip=CKV2_AWS_5:Modul referensi jaringan murni (tanpa resource compute). Attachment SG ke EC2/ALB/ASG dibuat pada modul komputasi di implementasi lanjutan.
  name        = "${var.name_prefix}-app-sg"
  description = "API gateway / digital channel services"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-app-sg"
    zone = "app"
  }
}

resource "aws_security_group_rule" "app_ingress_dmz" {
  security_group_id        = aws_security_group.app.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.dmz.id
  description              = "fw #2 - DMZ ke App 443 (mTLS)"
}

resource "aws_security_group_rule" "app_egress_kafka" {
  security_group_id        = aws_security_group.app.id
  type                     = "egress"
  from_port                = 9093
  to_port                  = 9093
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.middleware.id
  description              = "fw #3 - App ke Middleware 9093 Kafka TLS"
}

# ---------------------------------------------------------------------------
# Middleware (ESB / message broker / orchestration)
# fw #3: App -> Middleware 9093
# fw #4: Middleware -> Core (on-premise, di luar cakupan cloud tier)
# ---------------------------------------------------------------------------
resource "aws_security_group" "middleware" {
  #checkov:skip=CKV2_AWS_5:Modul referensi jaringan murni (tanpa resource compute). Attachment SG ke EC2/ALB/ASG dibuat pada modul komputasi di implementasi lanjutan.
  name        = "${var.name_prefix}-middleware-sg"
  description = "ESB / message broker / orchestration"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-middleware-sg"
    zone = "middleware"
  }
}

resource "aws_security_group_rule" "middleware_ingress_kafka" {
  security_group_id        = aws_security_group.middleware.id
  type                     = "ingress"
  from_port                = 9093
  to_port                  = 9093
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "fw #3 - App ke Middleware 9093"
}

# ---------------------------------------------------------------------------
# Management (bastion / PAM)
# fw #6: Management -> semua zona 22/3389 via bastion; ingress dibatasi ke
# CIDR administratif (VPN + MFA), bukan dari internet.
# ---------------------------------------------------------------------------
resource "aws_security_group" "mgmt" {
  #checkov:skip=CKV2_AWS_5:Modul referensi jaringan murni (tanpa resource compute). Attachment SG ke EC2/ALB/ASG dibuat pada modul komputasi di implementasi lanjutan.
  name        = "${var.name_prefix}-mgmt-sg"
  description = "Akses administrasi via bastion/PAM - hanya CIDR administratif"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-mgmt-sg"
    zone = "mgmt"
  }
}

resource "aws_security_group_rule" "mgmt_ingress_ssh" {
  security_group_id = aws_security_group.mgmt.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_cidr]
  description       = "fw #6 - SSH via bastion dari CIDR admin"
}

resource "aws_security_group_rule" "mgmt_ingress_rdp" {
  security_group_id = aws_security_group.mgmt.id
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = [var.admin_cidr]
  description       = "fw #6 - RDP via bastion dari CIDR admin"
}