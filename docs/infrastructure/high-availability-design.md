# Desain High Availability (HA)

## 1. Target Layanan
| Sistem | Availability Target | Max Downtime/Tahun |
|---|---|---|
| Core Banking (posting, ledger) | 99.95% | ~4,4 jam |
| Payment Switching/Gateway | 99.99% | ~52 menit |
| Internet/Mobile Banking (channel) | 99.9% | ~8,8 jam |
| Internal Reporting/BI | 99.5% | ~43,8 jam |

## 2. Strategi Redundansi Berlapis
1. **Redundansi Komponen** — tidak ada single point of failure di level hardware (dual PSU, dual NIC, RAID, redundant switch).
2. **Redundansi Zona** — minimal 2 availability zone/rack berbeda dalam satu DC untuk service stateless.
3. **Redundansi Situs (Site)** — DC utama + DRC di lokasi geografis berbeda (mitigasi bencana regional, mengikuti pedoman jarak minimum BCP perbankan).
4. **Redundansi Jaringan Eksternal** — dual ISP, dual jalur DC-DRC.

## 3. Health Check & Self-Healing
- Load balancer melakukan active health check (interval pendek, mis. 5–10 detik) dan otomatis mengeluarkan node yang gagal dari pool.
- Kubernetes liveness/readiness probe mengganti pod yang unhealthy otomatis.
- Database menggunakan otomatis failover terkontrol (bukan fully-automatic untuk core ledger — untuk core kritikal, failover DB tetap membutuhkan konfirmasi manual/semi-otomatis guna menghindari split-brain yang merusak integritas keuangan).

## 4. Graceful Degradation
Saat terjadi gangguan parsial, sistem didesain untuk tetap melayani fungsi paling kritikal:
- Jika fraud-scoring-service down → fallback ke rule-based sederhana dengan limit transaksi lebih ketat (bukan total block), dengan notifikasi eskalasi ke tim risk.
- Jika notification-service down → transaksi tetap diproses, notifikasi di-queue dan dikirim setelah service pulih (tidak memblokir transaksi utama).
- Jika reporting-service down → tidak berdampak pada transaksi nasabah (isolasi resource/bulkhead).

## 5. Load Balancing & Traffic Management
- **Layer 7 routing** berbasis path/host untuk microservices.
- **Canary/Blue-Green deployment** — rilis baru menerima persentase kecil traffic dahulu (mis. 5%), dipantau error rate & latency, baru di-ramp up bertahap.
- **Rate limiting per client/API key** untuk mencegah satu klien menghabiskan kapasitas bersama.

## 6. Chaos Engineering & Uji Ketahanan
- Uji failover terjadwal (game day) minimal 2 kali setahun: simulasi kegagalan DC, kegagalan database primer, kegagalan network link ke DRC.
- Setiap game day menghasilkan laporan temuan & action item, ditindaklanjuti sebagai bagian dari continuous improvement.
