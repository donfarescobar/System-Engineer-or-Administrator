# AGENTS.md — Panduan untuk AI Agent

## 1. Tujuan File Ini
File ini adalah instruksi khusus bagi AI Agent (mis. Claude Code atau agent lain) yang membaca repositori dokumentasi ini untuk memahami, melanjutkan, mereplikasi, atau membangun implementasi nyata (kode/IaC) berdasarkan portofolio arsitektur Banking & Enterprise ini.

## 2. Konteks Singkat
Repo ini adalah **dokumentasi desain, bukan kode implementasi**. Ia mensimulasikan lingkungan Core Banking Platform skala menengah-besar dengan standar regulasi Indonesia (OJK, BI, UU PDP) ditambah standar internasional (ISO 27001, PCI-DSS, NIST). Jika diminta membangun kode/infrastruktur nyata dari dokumen ini, perlakukan dokumen di `docs/` sebagai **spesifikasi kebutuhan (requirements)**, bukan template yang dicopy mentah — sesuaikan dengan constraint nyata (skala tim, budget, tools yang tersedia).

## 3. Urutan Baca yang Direkomendasikan untuk Agent
1. `README.md` — index & ringkasan eksekutif.
2. `docs/architecture/system-architecture.md` — pahami komponen & alur transaksi kritikal dulu, sebelum menyentuh detail lain.
3. `docs/architecture/network-architecture.md` + `docs/infrastructure/*.md` — pahami topologi dan standar compute.
4. `docs/security/*.md` — pahami kontrol keamanan sebelum mengusulkan perubahan apa pun (banyak keputusan desain lain bergantung pada constraint keamanan ini).
5. `docs/data/*.md` — pahami klasifikasi & alur data sebelum membuat skema baru.
6. `docs/disaster-recovery/*.md` — pahami target RTO/RPO sebelum mengusulkan perubahan arsitektur yang mempengaruhi availability.
7. `docs/operations/*.md` — pahami bagaimana sistem dioperasikan sehari-hari (runbook, incident, change, monitoring).
8. `docs/cicd/cicd-pipeline.md` — pahami bagaimana perubahan kode sampai ke production.
9. `SKILL.md` — pahami filosofi/justifikasi keputusan (gunakan ini sebagai "prinsip default" saat harus mengambil keputusan yang tidak eksplisit tercantum di dokumen lain).

## 4. Aturan yang Harus Dipatuhi Agent Saat Melanjutkan Proyek Ini

### 4.1 Jangan Melanggar Prinsip Keamanan yang Sudah Ditetapkan
- Jangan pernah mengusulkan akses langsung dari internet/App zone ke Core/Restricted zone (lihat tabel firewall di `network-architecture.md` No. 5 — eksplisit **Deny**).
- Jangan menyimpan credential/secret di kode atau file konfigurasi biasa — selalu arahkan ke secret manager (lihat `application-architecture.md` §5 dan `iam-access-management.md` §4).
- Jangan mengusulkan solusi yang menghapus audit trail/log kritikal sebelum masa retensi selesai (lihat `data-classification-retention.md`).

### 4.2 Konsistensi Konsistensi Data
- Untuk apa pun yang menyentuh saldo/ledger/posting keuangan: **wajib strong consistency (ACID)**, gunakan pola saga/outbox seperti dijelaskan di `application-architecture.md` §4 — jangan menyederhanakan menjadi eventual consistency demi kemudahan implementasi.
- Idempotency key wajib untuk endpoint yang memicu efek finansial (lihat `application-architecture.md` §2).

### 4.3 Perubahan Infrastruktur
- Semua perubahan infrastruktur diasumsikan lewat IaC (Terraform/Ansible) dan pipeline CI/CD (lihat `cicd-pipeline.md`) — bila Agent diminta membuat resource baru, buatkan sebagai kode IaC, bukan instruksi manual step-by-step untuk dieksekusi di server langsung, kecuali eksplisit diminta sebagai runbook darurat.

### 4.4 Menghormati Klasifikasi Data
- Sebelum menulis skema data baru atau pipeline data baru, cek klasifikasinya di `data-classification-retention.md`. Data L4 (Restricted, mis. PII/kartu) memerlukan enkripsi & masking di lingkungan non-produksi — jangan pernah membuat skenario di mana data produksi asli disalin mentah ke DEV/SIT.

### 4.5 Ketika Informasi Tidak Lengkap
Jika Agent diminta melanjutkan/mengimplementasikan sesuatu yang detailnya tidak tercakup eksplisit di dokumen ini:
1. Cek `SKILL.md` §3 (cara berpikir senior engineer) sebagai prinsip default.
2. Pilih opsi yang **paling konservatif dari sisi keamanan & konsistensi data** di antara opsi yang sama-sama valid secara teknis.
3. Nyatakan asumsi secara eksplisit di output (jangan diam-diam mengasumsikan sesuatu yang berdampak besar, terutama terkait kepatuhan/regulasi).

## 5. Yang TIDAK Boleh Dilakukan Agent
- Jangan membuat dokumen ini seolah-olah representasi sistem bank sungguhan yang beroperasi (ini adalah portofolio/simulasi standar industri, bukan dokumentasi operasional bank nyata) — jika diminta menghasilkan konten yang mengklaim sebagai sistem bank tertentu yang benar-benar ada, klarifikasi bahwa ini adalah materi portofolio/latihan.
- Jangan generate kredensial, kunci privat, atau data nasabah fiktif yang menyerupai data asli (NIK, nomor kartu valid, dsb.) — cukup gunakan placeholder yang jelas-jelas ilustratif.
- Jangan menghapus/mengubah prinsip "no direct access to Core Zone" atau prinsip least-privilege lain hanya demi menyederhanakan sebuah implementasi kode contoh.

## 6. Format Output yang Diharapkan dari Agent
Jika diminta melanjutkan (mis. "buatkan kode Terraform untuk network-architecture.md ini" atau "buatkan skema database sesuai data-architecture.md"), Agent sebaiknya:
1. Merujuk eksplisit ke bagian dokumen mana yang menjadi acuan.
2. Menjelaskan asumsi tambahan yang diambil (karena dokumen ini adalah desain tingkat tinggi, bukan spesifikasi implementasi lengkap).
3. Menghasilkan artifact yang konsisten dengan penamaan & struktur zona yang sudah didefinisikan (lihat `network-architecture.md` §2 untuk skema subnet/zona, `infrastructure-standards.md` §3 untuk naming convention).

## 7. Ringkasan Cepat (TL;DR untuk Agent)
- Ini dokumentasi desain enterprise banking bertujuan portofolio, bukan sistem produksi nyata.
- Prinsip utama: **zero trust, least privilege, defense in depth, immutable infra, ACID untuk data finansial, semua perubahan lewat pipeline & tercatat**.
- Jika ragu, pilih opsi yang lebih aman & lebih auditable, dan nyatakan asumsi secara eksplisit.
