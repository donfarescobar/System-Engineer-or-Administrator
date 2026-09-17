variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "admin_cidr" {
  description = "CIDR administratif yang diperbolehkan masuk ke zona mgmt (VPN + MFA)."
  type        = string
}