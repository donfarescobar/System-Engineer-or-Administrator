# Manajemen Insiden (Incident Management)

## 1. Klasifikasi Severity
| Severity | Definisi | Contoh | Target Respons | Target Komunikasi Update |
|---|---|---|---|---|
| Sev1 | Layanan nasabah kritikal down/tidak dapat transaksi | Core banking down, payment gateway down total | Immediate, war-room dibentuk | Tiap 15–30 menit |
| Sev2 | Degradasi signifikan, sebagian nasabah terdampak | Latency tinggi, satu channel down (mis. mobile app), fitur tertentu error | < 1 jam | Tiap 1 jam |
| Sev3 | Dampak terbatas, ada workaround | Satu laporan internal terlambat, fitur non-kritikal error | Jam kerja | Update harian |
| Sev4 | Tidak berdampak langsung ke nasabah/bisnis | Isu kosmetik, log noise | Best effort | Sesuai kebutuhan |

## 2. Alur Penanganan Insiden

```
Deteksi (alert/laporan) → Triase & Klasifikasi Severity → Deklarasi Insiden
        → Pembentukan Incident Commander (IC) + war-room (jika Sev1/2)
        → Investigasi & Mitigasi (stop the bleeding dulu, root cause belakangan)
        → Layanan Pulih (mitigated) → Monitoring stabilitas
        → Resolved → Post-Incident Review (blameless) → Action Item → Closed
```

## 3. Peran dalam War-Room
| Peran | Tanggung Jawab |
|---|---|
| Incident Commander (IC) | Koordinasi keseluruhan, keputusan akhir, bukan mengerjakan fix teknis langsung |
| Technical Lead | Memimpin investigasi teknis & eksekusi mitigasi |
| Communication Lead | Update ke stakeholder internal, nasabah (jika perlu), sesuai interval yang disepakati |
| Scribe | Mencatat timeline kejadian secara real-time (untuk post-mortem & bukti audit) |

## 4. Prinsip "Mitigate First, Root Cause Later"
Prioritas saat insiden aktif adalah **memulihkan layanan** (mis. rollback, failover, scale up), bukan langsung mencari akar masalah mendalam. Root Cause Analysis (RCA) mendalam dilakukan setelah layanan stabil, dalam sesi Post-Incident Review.

## 5. Post-Incident Review (Blameless Postmortem)
Wajib dilakukan untuk setiap insiden Sev1 & Sev2, dalam waktu maksimal beberapa hari kerja setelah insiden resolved. Dokumen mencakup:
1. **Timeline** kejadian (dari deteksi hingga resolved).
2. **Dampak** (durasi downtime, jumlah nasabah/transaksi terdampak, estimasi kerugian bila relevan).
3. **Root Cause** (5 Whys atau metode analisis serupa).
4. **Apa yang berjalan baik** & **apa yang bisa diperbaiki** (proses, tooling, komunikasi).
5. **Action Items** dengan pemilik (owner) dan tenggat waktu jelas, ditindaklanjuti hingga selesai (tidak berhenti di dokumen).

**Prinsip blameless**: fokus pada perbaikan sistem/proses, bukan mencari siapa yang "disalahkan" — agar tim tidak menyembunyikan informasi penting demi RCA yang jujur.

## 6. Kewajiban Pelaporan Regulator
- Insiden TI yang berdampak signifikan pada layanan perbankan wajib dilaporkan ke OJK/BI sesuai ketentuan waktu yang berlaku (dikoordinasikan oleh Compliance/Legal Liaison, bukan tim teknis langsung).
- Dokumentasi insiden (timeline, dampak, mitigasi, RCA) menjadi bagian dari bukti kepatuhan pelaporan.

## 7. Komunikasi ke Nasabah
- Untuk insiden yang berdampak layanan publik (Sev1/Sev2), disiapkan template komunikasi (status page, notifikasi in-app, media sosial resmi) yang disetujui Communication Lead — informasi jujur tanpa detail teknis sensitif yang bisa disalahgunakan.

## 8. Metrik Kematangan Incident Management
- **MTTD** (Mean Time to Detect).
- **MTTA** (Mean Time to Acknowledge).
- **MTTR** (Mean Time to Resolve/Recover).
- **Jumlah insiden berulang** (repeat incident) — indikator apakah action item dari postmortem benar-benar efektif.
