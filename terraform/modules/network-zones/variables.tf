variable "name_prefix" {
  description = "Prefiks penamaan, format <env>-<dc> (lihat infrastructure-standards.md bab 3)."
  type        = string
}

variable "vpc_name" {
  description = "Nama VPC (sudah memakai prefiks penamaan)."
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnets" {
  description = "Map zona -> CIDR subnet. Key zona: dmz, app, middleware, mgmt."
  type        = map(string)
}

variable "az" {
  description = "AZ referensi untuk subnet."
  type        = string
}