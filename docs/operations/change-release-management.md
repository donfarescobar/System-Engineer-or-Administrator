# Manajemen Perubahan & Rilis (Change & Release Management)

## 1. Kategori Perubahan
| Kategori | Definisi | Approval | Contoh |
|---|---|---|---|
| Standard Change | Perubahan rutin, risiko rendah, sudah pernah dieksekusi & terbukti aman, mengikuti prosedur baku | Pre-approved (tidak perlu CAB per eksekusi) | Restart service rutin, scaling terjadwal |
| Normal Change | Perubahan terencana dengan risiko sedang | Change Advisory Board (CAB) | Rilis fitur baru, upgrade versi minor |
| Emergency Change | Perubahan mendesak untuk mengatasi insiden/kerentanan kritikal | Expedited approval (mis. IC + 1 senior approver), didokumentasikan retroaktif | Emergency patch CVE kritikal, hotfix insiden Sev1 |

## 2. Siklus Hidup Perubahan
```
Request → Assessment (risiko, dampak, rollback plan) → Approval (sesuai kategori)
   → Scheduling (jadwal & window) → Implementasi (via CI/CD, bukan manual)
   → Verifikasi (post-change validation) → Closure (dokumentasi hasil)
```

## 3. Change Advisory Board (CAB)
- Beranggotakan perwakilan: Engineering Lead, Security, Operations/SRE, Business Owner terkait.
- Menilai: dampak risiko, ketergantungan sistem lain, rencana rollback, jadwal (hindari bentrok dengan periode volume transaksi tinggi), kelengkapan test.
- Perubahan yang menyentuh Core Banking/data finansial mendapat scrutiny lebih tinggi (mis. wajib ada sign-off dari unit risk/compliance).

## 4. Wajib Melekat pada Setiap Change Request
1. **Deskripsi perubahan** & alasan bisnis/teknis.
2. **Rencana implementasi** step-by-step (atau referensi ke pipeline otomatis).
3. **Rencana rollback** yang sudah diuji (bukan asumsi "seharusnya bisa di-rollback").
4. **Rencana verifikasi** (bagaimana memastikan perubahan berhasil tanpa efek samping).
5. **Jadwal & window** pelaksanaan, termasuk estimasi durasi.
6. **Dampak terhadap SLA/availability** dan komunikasi ke stakeholder jika ada downtime terjadwal.

## 5. Freeze Period (Change Freeze)
- Periode tertentu (mis. akhir tahun, hari besar keagamaan, periode gajian massal) ditetapkan sebagai **change freeze** untuk sistem kritikal — hanya emergency change yang diperbolehkan, dengan approval lebih ketat.
- Tujuan: mengurangi risiko insiden pada periode volume transaksi tertinggi.

## 6. Integrasi dengan CI/CD
- Normal change untuk aplikasi (bukan infrastruktur besar) idealnya dieksekusi melalui pipeline otomatis yang sudah include automated testing & approval gate — bukan eksekusi manual oleh individu di server production (lihat `docs/cicd/cicd-pipeline.md`).
- Setiap deployment production tercatat otomatis (siapa, kapan, versi apa, hasil pipeline) sebagai bagian dari audit trail perubahan.

## 7. Post-Implementation Review
- Untuk perubahan besar (mis. migrasi infrastruktur, upgrade major version core banking), dilakukan review setelah periode stabilisasi (mis. 1–2 minggu pasca-implementasi) untuk memastikan tidak ada dampak tersembunyi (mis. peningkatan error rate halus, kebocoran memori bertahap).
