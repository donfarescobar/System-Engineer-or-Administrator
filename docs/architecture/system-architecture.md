# Arsitektur Sistem — Core Banking & Digital Channel Platform

## 1. Tujuan
Mendefinisikan gambaran arsitektur menyeluruh: komponen utama, batas kepercayaan (trust boundary), dan alur transaksi kritikal, sebagai acuan tunggal (single source of truth) bagi tim engineering maupun AI Agent yang membangun/mengaudit sistem ini.

## 2. Prinsip Desain (Architecture Principles)
1. **Defense in Depth** — Tidak ada satu kontrol keamanan tunggal yang dipercaya penuh; setiap layer (network, host, app, data) punya kontrolnya sendiri.
2. **Zero Trust Segmentation** — Tidak ada trust implisit antar-zona meski sama-sama internal network; setiap komunikasi antar-service diverifikasi (mTLS + service identity).
3. **Immutable Infrastructure** — Server tidak di-patch manual di production; image baru dibangun, di-deploy, yang lama ditarik (blue/green).
4. **Loose Coupling, High Cohesion** — Modul core banking (ledger, posting) dipisah dari channel (mobile, internet banking) via API Gateway & ESB/Event Bus.
5. **Fail-Safe Default** — Default deny pada firewall/IAM; whitelist eksplisit untuk setiap akses.
6. **Auditable by Design** — Semua transaksi keuangan dan perubahan konfigurasi menghasilkan audit trail immutable (WORM storage untuk log kritikal, retensi 10 tahun sesuai POJK).

## 3. Gambaran Besar (High-Level Architecture)

```
                          ┌───────────────────────────────────────────┐
                          │             ZONA PUBLIK (DMZ)              │
                          │  WAF │ Anti-DDoS │ Reverse Proxy │ CDN      │
                          └───────────────────┬───────────────────────┘
                                               │ mTLS
                          ┌───────────────────▼───────────────────────┐
                          │        API GATEWAY / EDGE LAYER            │
                          │  Rate limiting, AuthN/AuthZ (OAuth2/OIDC)  │
                          │  Request validation, API versioning        │
                          └───────────────────┬───────────────────────┘
                                               │
             ┌─────────────────────────────────┼─────────────────────────────────┐
             │                                 │                                 │
  ┌──────────▼─────────┐          ┌────────────▼───────────┐        ┌────────────▼───────────┐
  │  Digital Channel     │          │   Middleware / ESB      │        │  Payment Switching /     │
  │  Services (Mobile,   │          │   Event Bus (Kafka)      │        │  Interbank Gateway       │
  │  Internet Banking)   │          │   Orchestration Layer    │        │  (ISO8583/ISO20022)      │
  └──────────┬─────────┘          └────────────┬───────────┘        └────────────┬───────────┘
             │                                 │                                 │
             └─────────────────────────────────┼─────────────────────────────────┘
                                                │
                          ┌─────────────────────▼─────────────────────┐
                          │            CORE BANKING SYSTEM (CBS)        │
                          │  Ledger, Account Mgmt, Posting Engine       │
                          │  Batch/EOD Processing, Interest Calc        │
                          └─────────────────────┬─────────────────────┘
                                                │
                          ┌─────────────────────▼─────────────────────┐
                          │        DATA LAYER (Zona Terbatas/Trusted)   │
                          │  Primary DB (RAC/Cluster) │ DR Replica      │
                          │  Data Warehouse │ Audit Log Store (WORM)    │
                          └─────────────────────────────────────────────┘
```

## 4. Komponen Utama

| Layer | Komponen | Teknologi Referensi | Catatan Compliance |
|---|---|---|---|
| Edge/DMZ | WAF, Anti-DDoS, Reverse Proxy | F5/NGINX+, Cloudflare/Akamai | Wajib untuk channel publik (POJK IT Risk Management) |
| API Layer | API Gateway, Auth Server | Kong/Apigee, Keycloak (OIDC) | Token lifetime pendek, mTLS internal |
| Middleware | ESB, Message Broker | Kafka/IBM MQ, Camunda (orchestration) | Idempotency wajib untuk transaksi finansial |
| Core | Core Banking System | Vendor CBS (mis. Temenos/Finacle) atau custom ledger | Segregasi lingkungan dev/uat/prod ketat |
| Payment | Switching/Gateway | ISO8583 (kartu), ISO20022 (transfer) | Sertifikasi PCI-DSS jika proses kartu |
| Data | RDBMS Cluster, DWH | Oracle RAC/PostgreSQL cluster, Data Warehouse | Enkripsi at-rest (TDE), masking data PII |
| Observability | Log, Metric, Trace | ELK/Loki, Prometheus+Grafana, Jaeger | Log kritikal WORM, retensi sesuai regulasi |
| Security | IAM, PAM, SIEM | Vault, CyberArk, Splunk/QRadar | Privileged access recorded & reviewed berkala |

## 5. Alur Transaksi Kritikal (Contoh: Transfer Antar Bank)

1. Nasabah inisiasi transaksi via mobile app → TLS 1.2+ ke WAF/CDN.
2. API Gateway memvalidasi token OAuth2 & rate limit.
3. Request diteruskan ke Digital Channel Service → publish event ke Event Bus (idempotency key disertakan).
4. Middleware melakukan orkestrasi: cek saldo (call ke Core Banking), validasi anti-fraud (real-time scoring), lalu submit ke Payment Switching.
5. Payment Switching membentuk pesan ISO20022, kirim ke jaringan interbank (RTGS/SKN/BI-FAST).
6. Respon diterima → Core Banking melakukan posting ke ledger (double-entry, atomic transaction).
7. Notifikasi ke nasabah, audit log ditulis ke WORM store, metrik & trace dikirim ke observability stack.

**Failure mode yang diantisipasi:**
- Timeout ke jaringan interbank → status transaksi "pending reconciliation", job rekonsiliasi H+0 malam hari mencocokkan status.
- Duplicate request (retry dari client) → ditangani via idempotency key di layer middleware.
- Partial failure (saldo terpotong tapi posting gagal) → saga pattern dengan compensating transaction.

## 6. Batas Kepercayaan (Trust Boundaries)

| Zona | Trust Level | Kontrol Masuk |
|---|---|---|
| Internet | Untrusted | WAF, Anti-DDoS |
| DMZ | Low Trust | Firewall L4/L7, IPS |
| Application Zone | Medium Trust | Segmentasi VLAN, mTLS antar service |
| Core/Data Zone | High Trust (Restricted) | Jump server/bastion only, PAM, no direct internet route |
| Management/OOB Network | Separate plane | Out-of-band, akses hanya via VPN + MFA + PAM |

## 7. Keputusan Arsitektur Kunci (ADR Ringkas)

- **ADR-01**: Core Banking tetap on-premise (bukan public cloud) — alasan: kepatuhan data residency & kontrol audit fisik data center sesuai ketentuan OJK terkait Penyelenggara Jasa Sistem Pembayaran/Bank.
- **ADR-02**: Digital channel & analytics workload boleh di hybrid/private cloud — alasan: elastisitas beban (mis. saat promo/payday) tanpa menyentuh data core.
- **ADR-03**: Event-driven middleware (Kafka) dipilih daripada point-to-point integration — alasan: decoupling, replay capability untuk audit/rekonsiliasi.
- **ADR-04**: Seluruh komunikasi service-to-service wajib mTLS — alasan: zero trust, mitigasi lateral movement jika satu segmen network dikompromikan.
