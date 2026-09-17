# Kebijakan Backup & Restore

## 1. Prinsip
- **3-2-1 Rule (minimum)**: minimal 3 salinan data, di 2 media berbeda, dengan 1 salinan off-site/off-network.
- **Immutable Backup**: minimal satu salinan backup bersifat WORM (tidak bisa diubah/dihapus meski akun admin dikompromikan) — mitigasi utama terhadap ransomware.
- **Backup Diuji, Bukan Diasumsikan** — backup yang tidak pernah di-restore-test dianggap tidak valid.

## 2. Jadwal Backup
| Jenis Data | Metode | Frekuensi | Retensi |
|---|---|---|---|
| Database Core Banking | Full + incremental/log shipping | Full mingguan, incremental/log tiap beberapa menit (untuk PITR) | Sesuai kebijakan retensi data terkait |
| Database Service (microservices) | Snapshot otomatis | Harian | 30 hari rolling + arsip bulanan |
| Konfigurasi Infrastruktur (IaC state) | Version control + snapshot | Setiap perubahan (via Git) | Selamanya (Git history) |
| File/Object Storage | Replikasi + snapshot | Harian | Sesuai klasifikasi data |
| VM/Container Image (golden image) | Registry versioning | Setiap build | Simpan N versi terakhir minimum |

## 3. Keamanan Backup
- Backup terenkripsi (at-rest & in-transit saat proses backup/restore).
- Kredensial akses sistem backup terpisah dari kredensial administrasi produksi sehari-hari (mencegah satu akun kompromi menghapus data produksi sekaligus backup-nya).
- Backup disimpan di segmen jaringan terisolasi dari domain produksi utama (air-gapped/logical isolation) untuk mitigasi ransomware lateral movement.

## 4. Uji Restore
- **Restore test terjadwal** minimal triwulanan untuk sistem kritikal, memverifikasi:
  - Data dapat direstore dalam RTO yang ditetapkan.
  - Integritas data pasca-restore (checksum/reconciliation).
  - Dokumentasi prosedur restore masih akurat (siapa pun di tim, bukan hanya satu orang, dapat mengeksekusi).
- Hasil uji restore didokumentasikan sebagai bukti kepatuhan audit.

## 5. Prosedur Restore (Ringkas)
1. Identifikasi titik waktu pemulihan (recovery point) yang dibutuhkan.
2. Isolasi environment target restore (hindari restore langsung menimpa produksi tanpa validasi).
3. Eksekusi restore sesuai runbook per sistem.
4. Validasi integritas data (reconciliation dengan sumber lain jika memungkinkan).
5. Approval sebelum data hasil restore digunakan kembali untuk layanan produksi.
6. Dokumentasikan durasi aktual vs RTO target, catat sebagai lesson learned jika melebihi target.

## 6. Retensi & Pemusnahan Backup
- Backup yang telah melewati masa retensi wajib dihapus/dimusnahkan secara terjadwal (bukan menumpuk tanpa batas), mengikuti kebijakan `data-classification-retention.md`.
- Pemusnahan media backup fisik (jika ada, mis. tape) mengikuti standar sanitasi data dengan berita acara.
