# SKILL.md — Kompetensi Senior System Engineer / Infrastructure Administrator (Domain Banking & Enterprise)

## 1. Tujuan Dokumen
File ini menjelaskan **kompetensi & keputusan teknis** yang mendasari seluruh dokumen di `docs/`. Berbeda dari dokumen arsitektur (apa yang dibangun), file ini menjelaskan **mengapa seorang senior engineer mengambil keputusan tersebut** — berguna sebagai referensi penilaian portofolio maupun konteks bagi AI Agent yang ingin melanjutkan/mereplikasi keputusan yang konsisten.

## 2. Kompetensi Inti

### 2.1 Infrastructure & Platform
- Desain HA/DR multi-datacenter, kapasitas planning, IaC (Terraform/Ansible), containerization (Kubernetes/OpenShift), virtualisasi enterprise (VMware/KVM).
- Storage tiering & enkripsi at-rest, backup/restore strategy dengan uji nyata (bukan asumsi).
- Standarisasi golden image & immutable infrastructure, mengurangi configuration drift.

### 2.2 Network Engineering
- Segmentasi zona (DMZ, app, middleware, restricted core) berbasis zero-trust.
- Firewall policy design berbasis least-privilege (default-deny + whitelist eksplisit).
- Redundansi jaringan (dual ISP, dual jalur DC-DRC, HA firewall/load balancer).

### 2.3 Security Engineering & Compliance
- Pemetaan kontrol teknis terhadap regulasi (POJK, UU PDP, PCI-DSS, ISO 27001) — bukan menghafal regulasi, tapi menerjemahkannya menjadi kontrol teknis konkret.
- IAM/PAM design: least privilege, JIT access, segregation of duties.
- Vulnerability management dengan SLA berbasis risiko (CVSS), bukan patch sembarangan.

### 2.4 Site Reliability Engineering (SRE)
- Observability (metrics, logs, traces) sebagai bagian Definition of Done, bukan tambahan setelah insiden terjadi.
- Incident management dengan disiplin severity tiering, blameless postmortem, dan metrik MTTD/MTTA/MTTR.
- Chaos engineering & game day untuk memvalidasi asumsi HA/DR secara berkala (bukan hanya di atas kertas).

### 2.5 DevOps & Release Engineering
- CI/CD dengan security gate terintegrasi (shift-left), bukan security sebagai langkah terpisah di akhir.
- Strategi rilis aman (canary, blue-green, feature flag) untuk meminimalkan blast radius perubahan.
- Change management yang membedakan standard/normal/emergency change sesuai tingkat risiko.

### 2.6 Data Engineering & Governance
- Desain data flow yang membedakan konsistensi kuat (ledger) vs eventual consistency (analitik).
- Klasifikasi & retensi data yang selaras dengan kewajiban regulasi, bukan retensi sembarangan.
- Data lineage & reconciliation sebagai kontrol kualitas data harian (bukan hanya saat audit).

## 3. Cara Berpikir Senior Engineer yang Tercermin di Dokumen Ini
1. **Trade-off eksplisit** — setiap keputusan besar (mis. core banking tetap on-prem) disertai alasan, bukan sekadar preferensi teknologi.
2. **Failure mode dipikirkan lebih dulu** — desain bukan hanya "bagaimana normal berjalan", tapi "apa yang terjadi saat gagal" (partial failure, network partition, duplicate request).
3. **Automasi di atas proses manual** — manual step dianggap risiko (human error, tidak scalable, sulit diaudit), bukan solusi default.
4. **Audit & kepatuhan sebagai bagian desain**, bukan lapisan tambahan setelah sistem jadi.
5. **Blameless & continuous improvement** — insiden dan kegagalan dilihat sebagai sumber perbaikan sistem/proses, bukan alat mencari kesalahan individu.

## 4. Pemetaan Skill ke Dokumen
| Skill | Dokumen Terkait |
|---|---|
| Arsitektur sistem & keputusan desain | `docs/architecture/*.md` |
| Infrastruktur & HA | `docs/infrastructure/*.md` |
| Keamanan & kepatuhan | `docs/security/*.md` |
| Data governance | `docs/data/*.md` |
| Business continuity | `docs/disaster-recovery/*.md` |
| Operasional & SRE | `docs/operations/*.md` |
| Release engineering | `docs/cicd/cicd-pipeline.md` |

## 5. Sertifikasi/Referensi yang Relevan (Ilustratif, untuk Konteks Portofolio)
- ITIL Foundation (manajemen layanan IT, change/incident management).
- ISO/IEC 27001 Lead Implementer/Auditor (ISMS).
- Cloud/Infra: Kubernetes (CKA), vendor cloud tertentu jika hybrid.
- Security: CISSP/CISM (governance-level), OSCP (teknis-level, opsional tergantung fokus karier).
- PCI-DSS Implementer (jika berkecimpung di payment processing).
