terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.66"
    }
  }

  # Backend sengaja tidak di-hardcode agar `terraform init -backend=false`
  # tetap bisa dipakai untuk validasi lokal. Pada pipeline production
  # (lihat cicd-pipeline.md bab 6), backfill dengan backend remote dan state
  # locking, misal lewat -backend-config:
  #
  #   terraform init -backend-config=bucket=<state-bucket> \
  #                  -backend-config=dynamodb_table=<tf-lock-table>
  #
  # Kredensial tidak pernah ditulis di file konfigurasi repo ini.
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      portfolio   = "banking-enterprise"
      managed-by  = "terraform"
      environment = var.environment
    }
  }
}

locals {
  name_prefix = "${var.environment}-${var.dc}"
}

module "network_zones" {
  source      = "./modules/network-zones"
  name_prefix = local.name_prefix
  vpc_name    = "${local.name_prefix}-vpc"
  vpc_cidr    = var.vpc_cidr
  subnets     = var.subnets
  az          = var.az
}

module "zone_security" {
  source      = "./modules/zone-security"
  name_prefix = local.name_prefix
  vpc_id      = module.network_zones.vpc_id
  admin_cidr  = var.admin_cidr
}