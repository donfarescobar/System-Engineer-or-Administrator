# Terraform: Network & Security Group (Cloud Tier Non-Core)

Implementasi referensi untuk **tier non-core di hybrid cloud**, menerjemahkan
pola zonasi jaringan pada `docs/architecture/network-architecture.md` dan
standar `docs/infrastructure/infrastructure-standards.md`.

> Penting: sesuai ADR-01 (`docs/architecture/system-architecture.md`),
> core banking tetap on-premise. Repositori ini hanya memodelkan bagian yang
> memang boleh di cloud (ADR-02: digital channel & analytics).

## Pemetaan aturan firewall ke resource

Tabel kebijakan firewall `network-architecture.md` bab 5 diterjemahkan
menjadi security group default-deny:

| No | Source | Dest | Port | Resource |
|---|---|---|---|---|
| 1 | Internet | DMZ | 443 | `dmz_ingress_443` |
| 2 | DMZ | App | 443 (mTLS) | `dmz_egress_app` + `app_ingress_dmz` |
| 3 | App | Middleware | 9093 | `app_egress_kafka` + `middleware_ingress_kafka` |
| 4 | Middleware | Core | 1521 | On-premise — di luar cakupan |
| 5 | Any | Core | Any (deny) | Tidak ada rute/rule yang dibuat (default-deny) |
| 6 | Management | Semua zona | 22/3389 | `mgmt_ingress_ssh/rdp` (dibatasi `admin_cidr`) |
| 7 | Core | Internet | Any (deny) | On-premise — di luar cakupan |

## Struktur

```
terraform/
├── main.tf          # provider, module call, naming <env>-<dc>
├── variables.tf     # subnet map mengikuti tabel zona (10.10.1, 10.10.10, ...)
├── outputs.tf
└── modules/
    ├── network-zones/   # VPC + subnet per zona + routing (DMZ publik, sisanya privat)
    └── zone-security/   # Security group per zona (default-deny)
```

Subnet per zona mengikuti angka persis pada `network-architecture.md`:

| Zona | CIDR |
|---|---|
| dmz | 10.10.1.0/24 |
| app | 10.10.10.0/23 |
| middleware | 10.10.20.0/24 |
| mgmt | 10.10.99.0/24 |

## Cara menjalankan

```bash
# Pra-syarat: AWS creds via env / OIDC. Untuk plan/apply, sediakan admin_cidr.
cd terraform
terraform init -backend=false        # validasi lokal tanpa backend remote
terraform fmt -check -recursive
terraform validate

# Plan/apply di production dilakukan via pipeline (cicd), bukan manual.
```

## Trade-off yang disengaja

- **Satu AZ per subnet** — referensi ini memprioritaskan keterbacaan dan
  kesesuaian 1:1 dengan tabel subnet dokumen. Untuk produksi, replikasi
  subnet antar-AZ dan NAT path tambahan diperlukan sesuai
  `docs/infrastructure/high-availability-design.md`.
- **Tidak ada gateway NAT** — zona privat tidak punya rute internet (default
  deny). Egress update dipisahkan lewat zona mgmt, selaras dengan prinsip
  deny outbound pada dokumen.
- **`admin_cidr` wajib diisi** — tanpa nilai, plan/apply gagal. Ini sengaja,
  mencegah akses manajemen terbuka ke 0.0.0.0/0. Gunakan variable file
  (`envs/prod/terraform.tfvars`) atau CI secret.

## Tambahan yang ikut diterapkan

- **Default security group VPC dikosongkan** (default-deny), bukan dibiarkan
  dengan rule bawaan yang mengizinkan seluruh traffic.
- **VPC flow logging** ke CloudWatch Log Group (terenkripsi KMS, rotasi key
  aktif, retensi 365 hari) sebagai kontrol deteksi anomali jaringan.
- Subnet DMZ tidak auto-assign public IP ke instance; endpoint publik hanya
  dilekatkan ke load balancer internet-facing.