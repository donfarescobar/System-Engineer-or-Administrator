# Runbook & SOP Operasional

## 1. Prinsip Runbook
- Setiap runbook ditulis dengan asumsi pembaca **belum tentu ahli konteks penuh** (bisa on-call engineer yang baru bergabung, atau AI Agent) — instruksi harus eksplisit, bukan mengandalkan tacit knowledge.
- Setiap langkah punya **expected outcome** dan **langkah jika gagal (fallback)**.
- Runbook diuji berkala (dry-run) agar tidak basi (out of date) dibanding kondisi sistem sebenarnya.

## 2. Format Standar Runbook
```
# Runbook: <Nama Prosedur>
## Trigger
Kapan runbook ini dijalankan (mis. alert spesifik, permintaan change, jadwal rutin)
## Prasyarat
Akses/tool yang dibutuhkan, izin yang harus sudah ada
## Langkah Eksekusi
1. ...
2. ...
## Validasi Keberhasilan
Bagaimana memastikan langkah berhasil
## Rollback
Langkah jika terjadi kegagalan
## Eskalasi
Siapa yang dihubungi jika runbook tidak menyelesaikan masalah
```

## 3. Contoh Runbook: Restart Service Aplikasi Kritikal (Rolling, Tanpa Downtime)
**Trigger**: Alert memory leak/high error rate pada `transfer-orchestrator`.
**Prasyarat**: Akses kubectl read/exec sesuai RBAC namespace terkait, tiket change approved (untuk restart terjadwal) atau incident ticket (untuk emergency).
**Langkah**:
1. Verifikasi jumlah replica sehat saat ini (`kubectl get pods -n transfer`).
2. Pastikan minimal N-1 replica tetap sehat sebelum me-restart 1 pod (hindari restart serentak seluruh replica).
3. Restart pod satu per satu (`kubectl delete pod <pod-name>` — akan otomatis di-reschedule oleh deployment controller).
4. Tunggu readiness probe pod baru "Ready" sebelum lanjut ke pod berikutnya.
5. Pantau error rate & latency di dashboard selama proses berlangsung.
**Validasi**: Error rate kembali ke baseline, seluruh pod dalam status `Running` & `Ready`.
**Rollback**: Jika pod baru gagal start berulang kali → hentikan proses, revert ke image versi sebelumnya, eskalasi ke tim development.
**Eskalasi**: Jika tidak pulih dalam 15 menit → eskalasi ke Engineering Lead & buka incident bridge.

## 4. Contoh Runbook: Failover Database ke DR (Sistem Kritikal)
**Trigger**: Deklarasi disaster oleh Crisis Manager (lihat `dr-bcp-plan.md`), atau database primer unreachable > threshold yang disepakati.
**Prasyarat**: Akses PAM ke DB admin console, approval dari DR Coordinator.
**Langkah**:
1. Konfirmasi status replikasi DR (lag replikasi dalam batas RPO yang ditetapkan).
2. Hentikan aplikasi yang menulis ke database primer (mencegah split-brain/data divergence).
3. Promote replica DR menjadi primary.
4. Update connection string/service discovery agar aplikasi mengarah ke DB baru.
5. Jalankan smoke test transaksi end-to-end.
6. Buka kembali akses tulis aplikasi secara bertahap (canary → full).
**Validasi**: Transaksi test berhasil end-to-end, tidak ada error konsistensi data.
**Rollback**: Jika DR juga bermasalah → eskalasi ke Crisis Manager, pertimbangkan mode manual/darurat (mis. hold seluruh transaksi baru) sambil investigasi.
**Eskalasi**: Segera ke Crisis Manager & Compliance Liaison (kewajiban notifikasi regulator).

## 5. Contoh Runbook: Rotasi Sertifikat TLS Mendekati Kedaluwarsa
**Trigger**: Alert dari monitoring (sertifikat < 30 hari sebelum expired).
**Langkah**:
1. Ajukan/renew sertifikat baru (internal CA atau public CA sesuai jenis endpoint).
2. Deploy sertifikat baru ke secret manager/load balancer secara rolling (tanpa downtime, load balancer mendukung hot reload cert).
3. Verifikasi endpoint menggunakan sertifikat baru (`openssl s_client` atau tool monitoring cert).
4. Hapus sertifikat lama dari store setelah masa tenggang aman.
**Validasi**: Browser/klien tidak menunjukkan warning sertifikat, monitoring cert expiry menunjukkan tanggal baru.
**Eskalasi**: Jika proses renewal CA eksternal terlambat → gunakan sertifikat sementara/self-extend sesuai kebijakan darurat, eskalasi ke security team.

## 6. Checklist SOP Harian Tim Operasional (On-Call)
- [ ] Verifikasi seluruh dashboard health check hijau di awal shift.
- [ ] Cek antrian alert yang belum ter-acknowledge dari shift sebelumnya.
- [ ] Verifikasi hasil job batch EOD (End of Day) semalam berhasil tanpa anomali.
- [ ] Cek kapasitas storage/backup job berjalan sesuai jadwal.
- [ ] Serah terima (handover) shift dengan catatan tertulis (bukan lisan saja).
