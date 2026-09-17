# Keamanan & Kepatuhan (Security & Compliance)

## 1. Kerangka Regulasi & Standar yang Diacu
| Regulasi/Standar | Cakupan |
|---|---|
| POJK (OJK) terkait Manajemen Risiko TI Perbankan | Tata kelola risiko IT, BCP/DRP, outsourcing TI |
| Peraturan Bank Indonesia terkait Sistem Pembayaran | Standar keamanan payment gateway/switching |
| UU PDP (Pelindungan Data Pribadi) | Perlindungan data pribadi nasabah |
| ISO/IEC 27001 | Information Security Management System (ISMS) |
| PCI-DSS | Wajib jika sistem memproses/menyimpan data kartu pembayaran |
| SNI ISO 22301 / ISO 22301 | Business Continuity Management |
| NIST Cybersecurity Framework | Referensi kontrol teknis tambahan (identify, protect, detect, respond, recover) |

## 2. Struktur Kontrol Keamanan (Defense in Depth)

### 2.1 Preventive Controls
- Firewall, WAF, segmentasi jaringan (lihat `network-architecture.md`).
- IAM dengan least privilege + role-based access control (RBAC), lihat `iam-access-management.md`.
- Enkripsi data in-transit (TLS 1.2+/1.3) dan at-rest (AES-256).
- Hardening baseline (CIS Benchmark) — lihat `hardening-baseline.md`.
- Secure SDLC: SAST, SCA (dependency scanning), secret scanning di setiap pipeline CI.

### 2.2 Detective Controls
- SIEM terpusat — agregasi log dari seluruh zona (network, host, aplikasi, database).
- IDS/IPS di setiap boundary zona.
- File Integrity Monitoring (FIM) pada server core banking.
- Anomaly detection untuk pola transaksi mencurigakan (fraud detection engine).
- Vulnerability scanning berkala (internal & eksternal), pentest tahunan oleh pihak independen.

### 2.3 Responsive Controls
- Incident Response Plan terdokumentasi (lihat `docs/operations/incident-management.md`) dengan playbook per jenis insiden (mis. data breach, ransomware, DDoS, fraud transaksi).
- SOC (Security Operations Center) 24/7 untuk sistem kritikal, dengan eskalasi tier 1→2→3.
- Forensic readiness — retensi log & snapshot cukup untuk investigasi (WORM untuk log kritikal).

### 2.4 Corrective/Recovery Controls
- DR/BCP (lihat `docs/disaster-recovery/dr-bcp-plan.md`).
- Post-incident review wajib (blameless postmortem) untuk setiap insiden Sev1/Sev2.

## 3. Klasifikasi Data & Prinsip Perlindungan
- **Data sangat sensitif** (nomor kartu, PIN, data biometrik): tokenisasi/enkripsi, akses dibatasi aplikasi tertentu (need-to-know), tidak pernah muncul di log plaintext.
- **Data pribadi (PII)**: enkripsi at-rest, masking di lingkungan non-produksi, retensi sesuai kebutuhan bisnis & regulasi, hak subjek data (akses/hapus) difasilitasi sesuai UU PDP.
- **Data internal/operasional**: kontrol akses standar RBAC.
- **Data publik**: tanpa kontrol khusus.

## 4. Segregation of Duties (SoD)
- Tidak ada satu individu yang memiliki hak penuh dari pengembangan → deployment → akses data produksi tanpa persetujuan berlapis.
- Developer tidak memiliki akses langsung ke database produksi (akses via break-glass procedure dengan approval & audit log penuh).
- Perubahan kode wajib code review oleh pihak berbeda dari penulis kode.

## 5. Audit & Assessment Berkala
| Aktivitas | Frekuensi |
|---|---|
| Vulnerability scanning internal | Bulanan |
| Penetration test eksternal | Tahunan (atau setelah perubahan besar) |
| Review akses (user access review) | Triwulanan |
| Audit kepatuhan internal (ISMS) | Tahunan |
| Tabletop exercise insiden keamanan | Semesteran |
| DR/BCP test | Minimal 1x/tahun (full failover), tabletop lebih sering |

## 6. Manajemen Kerentanan (Vulnerability Management)
- SLA remediasi berdasarkan severity (CVSS):
  - Critical (9.0–10.0): remediasi ≤ 72 jam (emergency change).
  - High (7.0–8.9): remediasi ≤ 14 hari.
  - Medium (4.0–6.9): remediasi ≤ 30 hari.
  - Low (<4.0): remediasi siklus patch reguler.
- Exception/risk acceptance harus disetujui oleh pemilik risiko (risk owner) dengan compensating control terdokumentasi, bukan dibiarkan tanpa catatan.
