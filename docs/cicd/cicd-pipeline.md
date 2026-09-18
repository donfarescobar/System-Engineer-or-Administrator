# CI/CD Pipeline

## 1. Prinsip
1. **Tidak ada deployment manual ke production** — seluruh perubahan lewat pipeline terotomasi, dapat diaudit (siapa memicu, commit apa, hasil test apa).
2. **Shift-Left Security** — pengujian keamanan (SAST, SCA, secret scanning) dijalankan seawal mungkin di pipeline, bukan hanya sebelum rilis.
3. **Fail Fast** — pipeline berhenti di tahap paling awal yang mendeteksi masalah, agar feedback ke developer cepat.
4. **Immutable Artifact** — artifact/image yang diuji di staging adalah persis artifact yang sama yang dideploy ke production (bukan build ulang di production).

## 2. Tahapan Pipeline (Ilustratif)

```
Commit/PR → Build → Unit Test → SAST + SCA + Secret Scan
   → Package (image/artifact) → Push ke Registry (tagged & signed)
   → Deploy ke SIT/UAT → Integration Test + Automated Regression
   → Deploy ke Staging → Performance/Load Test + Security DAST
   → Approval Gate (Change Management, khusus Normal Change)
   → Deploy ke Production (Canary/Blue-Green)
   → Post-Deploy Smoke Test → Monitoring Ramp-Up → Full Rollout
```

## 3. Kontrol per Tahap
| Tahap | Kontrol | Kegagalan → Aksi |
|---|---|---|
| Build | Reproducible build, dependency lock file | Pipeline gagal, developer diberi tahu detail error |
| Unit Test | Coverage threshold minimum | Merge diblokir jika coverage turun signifikan |
| SAST/SCA | Tidak ada critical/high vulnerability baru | Pipeline gagal, wajib remediasi atau exception disetujui security |
| Secret Scanning | Tidak ada kredensial hardcoded di commit | Pipeline gagal, commit ditolak |
| Image Signing | Artifact ditandatangani (mis. cosign) | Deployment ditolak jika signature tidak valid (supply chain security) |
| Integration Test | Skenario end-to-end lintas service | Deployment ke staging diblokir |
| Performance Test | Latency/throughput sesuai baseline SLA | Rilis ditunda, investigasi regresi performa |
| DAST | Scan kerentanan aplikasi berjalan | Blocking untuk high/critical finding |
| Approval Gate | Sesuai kategori change (lihat `change-release-management.md`) | Deployment tertahan sampai approval |

## 4. Strategi Deployment Production
- **Canary Release**: rilis baru menerima persentase kecil traffic (mis. 5%→25%→50%→100%), dipantau golden signals di setiap tahap, auto-rollback jika error rate melebihi threshold.
- **Blue-Green Deployment**: untuk perubahan berisiko lebih tinggi/perubahan skema — environment baru (green) disiapkan penuh, traffic dialihkan sekaligus setelah verifikasi, environment lama (blue) tetap standby untuk rollback instan.
- **Feature Flag**: fitur baru di-deploy dalam kondisi "off", diaktifkan bertahap melalui flag tanpa perlu deployment ulang — memisahkan "deploy" dari "release".

## 5. Rollback Strategy
- Rollback otomatis dipicu oleh threshold metrik (error rate/latency) selama fase canary.
- Rollback manual selalu tersedia sebagai opsi ≤ 1 perintah/klik (bukan proses multi-langkah rumit saat kondisi darurat).
- Database migration mengikuti prinsip **backward-compatible migration** (expand-contract pattern) — skema baru tidak memutus versi aplikasi lama selama masa transisi, sehingga rollback aplikasi tidak memerlukan rollback skema database sekaligus.

## 6. Pipeline untuk Infrastruktur (IaC)
- Perubahan Terraform/Ansible melalui pull request → automated `plan`/dry-run → review manusia (wajib untuk perubahan production) → `apply` melalui pipeline (bukan dari laptop individu) → state tersimpan terpusat & terkunci (state locking) untuk mencegah konflik.

## 7. Audit Trail Deployment
Setiap deployment mencatat: commit hash, hasil seluruh test gate, siapa yang approve, waktu deployment, versi yang di-deploy sebelumnya (untuk rollback cepat), dan status akhir — tersimpan sebagai bagian dari bukti kepatuhan change management.
