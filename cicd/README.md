# Pipeline CI/CD

Direktori ini berisi penjelasan tentang bagaimana perubahan kode dan
infrastruktur dikirim ke production pada proyek ini. Implementasi workflow
aktual berada di `.github/workflows/`.

Acuan: `docs/cicd/cicd-pipeline.md` dan `docs/operations/change-release-management.md`.

## Dua jalur pipeline

### 1. CI (pull request) — `.github/workflows/ci.yml`

Dijalankan otomatis pada setiap PR ke `main`. Urutan gate mengikuti alur
dokumen: lint -> secret scan -> fmt/validate -> IaC security scan -> syntax
check -> validasi manifest Kubernetes.

| Tahap | Tooling | Referensi dokumen (cvss/SLA) |
|---|---|---|
| Secret scanning | gitleaks | cicd-pipeline.md bagian 3 |
| Terraform fmt + validate | hashicorp terraform | cicd-pipeline.md bagian 6 |
| IaC security scan | checkov, trivy | hardening-baseline.md bagian 7 |
| Manifest schema check | kubeconform | hardening-baseline.md bagian 4 |
| YAML lint | yamllint | - |

### 2. CD Terraform — `.github/workflows/cd-iac.yml`

- `plan` berjalan di environment `non-prod`, menghasilkan artifact plan yang
  tidak berubah ("immutable artifact").
- `apply` berada di environment `production` dengan **protection rules**
  (required reviewers) sebagai implementasi **approval gate** dari
  cicd-pipeline.md bagian 3 & change-release-management.md.
- Kredensial memakai OIDC federated role; state backend remote dengan
  DynamoDB locking (tidak ada `terraform apply` dari laptop).

## Konfigurasi yang dibutuhkan di GitHub

Sebelum workflow dapat berjalan, siapkan secret berikut di repo/setting:

| Secret | Guna |
|---|---|
| `AWS_ROLE_IAC` | ARN role OIDC untuk `terraform plan/apply` |
| `TF_STATE_BUCKET` | Bucket S3 penyimpanan tfstate |
| `TF_LOCK_TABLE` | Tabel DynamoDB untuk state locking |

Untuk perubahan masa depan (aplikasi service), tambahkan image build + sign
(cosign) pada CI sesuai cicd-pipeline.md bagian 3 (Image Signing).