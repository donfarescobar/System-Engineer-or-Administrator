# Arsitektur Aplikasi (Application Architecture)

## 1. Pola Arsitektur
Kombinasi **layered architecture** untuk Core Banking (karena butuh transaksi ACID ketat) dan **microservices berbasis event** untuk layanan channel/digital (karena butuh skalabilitas independen dan rilis cepat).

## 2. Prinsip Pengembangan
1. **API-First** — setiap kapabilitas bisnis diekspos sebagai API terdokumentasi (OpenAPI/Swagger) sebelum implementasi dimulai.
2. **Idempotency Wajib** — semua endpoint yang memicu efek finansial harus menerima `Idempotency-Key`.
3. **Backward Compatibility** — API versioning (URI atau header-based); breaking change wajib versi baru, versi lama di-deprecate bertahap (minimal 6 bulan overlap).
4. **12-Factor App** untuk service non-core: config via environment/secret manager (bukan hardcode), stateless process, log sebagai event stream.
5. **Circuit Breaker & Bulkhead** — setiap panggilan ke service eksternal/dependency dibungkus circuit breaker untuk mencegah cascading failure.

## 3. Katalog Layanan (Ilustratif)

| Service | Tanggung Jawab | Pola Komunikasi | SLA Internal |
|---|---|---|---|
| auth-service | AuthN/AuthZ, token issuance (OIDC) | Sync REST | 99.99% |
| account-service | Query saldo, mutasi, info rekening | Sync REST + cache | 99.95% |
| transfer-orchestrator | Orkestrasi alur transfer (saga) | Event-driven (Kafka) | 99.95% |
| fraud-scoring-service | Real-time scoring anti-fraud | Sync gRPC (low latency) | 99.9%, p99 < 150ms |
| notification-service | Push/SMS/email notifikasi | Async (event consumer) | Best effort, retry queue |
| ledger-posting-service | Posting ke core banking | Sync + outbox pattern | 99.99%, strong consistency |
| reporting-service | Laporan regulasi & internal | Batch + on-demand | Non-real-time |

## 4. Pola Integrasi dengan Core Banking
- **Outbox Pattern**: perubahan state di service lokal dan event yang akan dipublish ditulis dalam satu transaksi DB lokal, lalu relay ke Kafka — menghindari dual-write inconsistency.
- **Saga Pattern (Choreography/Orchestration)** untuk transaksi lintas service (contoh: transfer = debit source → credit destination → notifikasi), dengan compensating action jika salah satu langkah gagal.
- **Anti-Corruption Layer (ACL)**: service modern tidak memanggil API legacy Core Banking secara langsung, tapi melalui adapter yang menerjemahkan model data agar service modern tidak "tercemar" struktur data legacy.

## 5. Manajemen Konfigurasi & Rahasia (Secrets)
- Seluruh kredensial (DB password, API key, cert private key) disimpan di **secret manager** (mis. HashiCorp Vault), tidak pernah di source code/repo.
- Rotasi otomatis untuk credential database & service account (mis. setiap 90 hari atau on-demand saat insiden).
- Aplikasi mengambil secret saat startup via sidecar/agent injection, bukan environment variable statis di image.

## 6. Standar Kualitas Kode & Rilis
- Wajib code review (minimal 1 approver senior) sebelum merge ke branch utama.
- Static Application Security Testing (SAST) & dependency scanning (SCA) di setiap pipeline CI.
- Test coverage minimum disepakati tim (indikatif ≥ 80% untuk modul core finansial), termasuk skenario negative-path dan idempotency.
- Setiap service memiliki **runbook** dan **dashboard** sebelum dinyatakan "production ready" (bagian dari Definition of Done).
