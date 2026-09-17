# Rencana Disaster Recovery & Business Continuity (DR/BCP)

## 1. Tujuan
Memastikan layanan perbankan kritikal tetap dapat dipulihkan dalam target waktu yang ditetapkan saat terjadi gangguan besar (bencana alam, kegagalan data center, serangan siber skala besar).

## 2. Target Pemulihan (RTO/RPO)
| Sistem | RTO (Recovery Time Objective) | RPO (Recovery Point Objective) | Skema Replikasi |
|---|---|---|---|
| Core Banking (ledger, posting) | ≤ 1 jam | ≤ 5 menit | Synchronous/near-synchronous ke DRC |
| Payment Switching | ≤ 30 menit | ≤ 1 menit | Synchronous, active-active jika memungkinkan |
| Internet/Mobile Banking | ≤ 2 jam | ≤ 15 menit | Asynchronous replication + cache warm-up |
| Data Warehouse/Reporting | ≤ 8 jam | ≤ 24 jam | Batch replication |

## 3. Skenario yang Dicakup
1. **Kegagalan Data Center Primer** (bencana alam, kebakaran, listrik total) → failover penuh ke DRC.
2. **Kegagalan Parsial** (satu cluster/aplikasi down) → failover lokal dalam DC yang sama (tidak perlu site failover).
3. **Serangan Siber Skala Besar** (ransomware menyebar) → isolasi segmen terdampak, restore dari backup immutable (bukan dari sistem yang berpotensi terinfeksi).
4. **Kegagalan Jaringan Interbank/Payment Rail** → mode degradasi terkendali (mis. antrian transaksi, notifikasi ke nasabah), bukan penolakan total tanpa informasi.
5. **Gangguan Non-Teknis** (pandemi, akses fisik ke kantor terbatas) → rencana kerja jarak jauh untuk tim operasional kritikal, dengan akses VPN + MFA yang sudah diuji sebelumnya.

## 4. Struktur Tim Tanggap Darurat
| Peran | Tanggung Jawab |
|---|---|
| Crisis Manager | Keputusan strategis, komunikasi ke manajemen & regulator |
| DR Coordinator (Engineering Lead) | Eksekusi teknis failover, koordinasi tim infra/app |
| Communication Lead | Komunikasi ke nasabah, media, internal staff |
| Compliance/Legal Liaison | Memastikan pelaporan ke OJK/BI sesuai ketentuan waktu yang diwajibkan |
| Business Continuity Owner per Unit | Menjalankan rencana kontinuitas fungsi bisnis masing-masing |

## 5. Prosedur Failover Tingkat Tinggi (High-Level)
1. **Deteksi & Deklarasi**: monitoring mendeteksi outage → on-call engineer eskalasi ke DR Coordinator → keputusan deklarasi disaster oleh Crisis Manager (berdasarkan kriteria yang telah ditetapkan, mis. downtime > X menit atau dampak > Y nasabah).
2. **Aktivasi DRC**: tim menjalankan runbook failover terdokumentasi per sistem (lihat `docs/operations/runbooks-sop.md`), termasuk validasi integritas data sebelum DRC menerima traffic penuh.
3. **Redirect Traffic**: DNS/GSLB diarahkan ke DRC, atau BGP announcement DRC diaktifkan.
4. **Verifikasi Layanan**: smoke test transaksi end-to-end sebelum dinyatakan pulih untuk publik.
5. **Komunikasi**: update ke manajemen, regulator (sesuai kewajiban pelaporan insiden TI perbankan), dan nasabah (jika berdampak layanan).
6. **Failback**: setelah DC primer pulih, dilakukan sinkronisasi data dari DRC kembali ke primer, failback terjadwal di jam low-traffic dengan rencana rollback jika terjadi masalah.

## 6. Uji Coba (Testing) DR/BCP
| Jenis Uji | Frekuensi | Cakupan |
|---|---|---|
| Tabletop Exercise | Semesteran | Simulasi diskusi skenario, tanpa eksekusi teknis |
| Partial Failover Test | Triwulanan | Failover 1 sistem non-kritikal ke DRC |
| Full DR Test | Minimal 1x/tahun | Failover menyeluruh sistem kritikal, termasuk core banking (biasanya di luar jam operasional/akhir pekan) |
| Walkthrough Dokumen | Setelah setiap perubahan arsitektur signifikan | Validasi runbook masih sesuai kondisi terkini |

## 7. Ketergantungan Eksternal
- Vendor cloud/DC pihak ketiga (jika ada) wajib punya SLA dan bukti kepatuhan (mis. sertifikasi ISO 27001, laporan audit) yang tervalidasi.
- Kontrak vendor mencantumkan kewajiban notifikasi insiden dalam waktu tertentu, serta hak audit bagi bank.
