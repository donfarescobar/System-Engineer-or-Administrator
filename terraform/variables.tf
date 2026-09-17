variable "environment" {
  description = "Tujuan environment: dev, sit, uat, staging, prod (lihat server-compute-standards.md)."
  type        = string
  default     = "prod"
}

variable "dc" {
  description = "Penanda situs cloud tier, untuk korelasi dengan naming DC on-premise."
  type        = string
  default     = "cloud1"
}

variable "region" {
  description = "Region cloud tempat tier non-core berjalan. Core banking tetap on-premise (ADR-01)."
  type        = string
  default     = "ap-southeast-3"
}

variable "az" {
  description = "Availability zone referensi. Untuk produksi gunakan minimal 2 AZ (lihat high-availability-design.md)."
  type        = string
  default     = "ap-southeast-3a"
}

variable "vpc_cidr" {
  description = "CIDR VPC. Berisi seluruh subnet zona di bawah."
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnets" {
  description = "CIDR per zona, mengikuti tabel segmentasi di network-architecture.md paragraph 2."
  type        = map(string)
  default = {
    dmz        = "10.10.1.0/24"
    app        = "10.10.10.0/23"
    middleware = "10.10.20.0/24"
    mgmt       = "10.10.99.0/24"
  }
}

variable "admin_cidr" {
  description = "CIDR akses administratif (VPN + MFA). WAJIB diisi dari variable file/CI secret, bukan hardcode di repo."
  type        = string
  nullable    = false
}