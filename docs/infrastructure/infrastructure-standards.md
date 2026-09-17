# Standar Infrastruktur (Infrastructure Standards)

## 1. Filosofi
Infrastruktur dikelola sebagai kode (**Infrastructure as Code / IaC**) — tidak ada perubahan manual di production tanpa jejak (drift terdeteksi otomatis via reconciliation loop).

## 2. Lapisan Infrastruktur

### 2.1 Compute
- **Virtualisasi**: VMware vSphere/KVM untuk workload tradisional (Core Banking vendor yang tidak container-ready).
- **Container Orchestration**: Kubernetes (on-prem, mis. OpenShift/Rancher) untuk microservices & digital channel.
- **Bare Metal**: dipertahankan untuk database primer (performa I/O maksimal, lisensi core-based).
- **Standar sizing**: kapasitas dirancang untuk menahan beban puncak (peak) + headroom 30%, disertai auto-scaling untuk tier stateless.

### 2.2 Storage
- **Tier 1 (Core DB)**: All-flash SAN, replikasi sinkron ke DR (dalam radius latency rendah) untuk RPO mendekati nol.
- **Tier 2 (App/log)**: Hybrid SAN/NAS.
- **Tier 3 (Archive/Backup)**: Object storage dengan WORM (immutability) untuk kebutuhan retensi regulasi.
- **Enkripsi**: seluruh storage tier menggunakan enkripsi at-rest (AES-256), key dikelola KMS terpisah dari data.

### 2.3 Networking (ringkas — detail di `network-architecture.md`)
- SDN untuk fleksibilitas segmentasi microservices.
- Load balancer L4/L7 redundant di setiap tier.

### 2.4 Database
- **Core Banking DB**: cluster (RAC atau setara), synchronous replication ke DR site untuk zona kritikal.
- **Service DB (microservices)**: pola database-per-service, backup otomatis harian + point-in-time recovery (PITR).
- **Connection pooling** wajib (PgBouncer/ODP) untuk mencegah connection exhaustion saat traffic tinggi.

## 3. Standar Naming Convention
```
<env>-<region/dc>-<layer>-<app>-<number>
Contoh: prod-dc1-app-transfersvc-01
         dr-dc2-db-core-primary
```

## 4. Standar Patching & Lifecycle Management
- **Patch window** terjadwal bulanan (di luar jam sibuk transaksi, biasanya dini hari weekend), dengan exception untuk **critical security patch (CVSS ≥ 9.0)** yang wajib di-emergency-patch dalam 72 jam melalui expedited change process.
- **OS/firmware EOL tracking**: setiap komponen infrastruktur punya tanggal EOL/EOS yang dipantau, migrasi direncanakan minimal 12 bulan sebelum EOL.
- **Golden image**: seluruh VM/container base image di-build dari template yang sudah di-hardened (lihat `hardening-baseline.md`), bukan instalasi manual per server.

## 5. Kapasitas & Performance Management
- Baseline kapasitas ditinjau triwulanan (CPU, memori, storage, IOPS, network throughput).
- Threshold alert: 70% (warning), 85% (critical) untuk utilisasi resource utama.
- Load testing wajib sebelum rilis besar atau menjelang periode volume tinggi (mis. akhir bulan gajian, hari besar keagamaan/liburan — pola transaksi perbankan Indonesia meningkat signifikan).

## 6. Manajemen Aset & Inventarisasi
- CMDB (Configuration Management Database) menjadi single source of truth seluruh aset (server, jaringan, aplikasi, ketergantungan/dependency mapping).
- Setiap perubahan konfigurasi infrastruktur wajib tercermin di CMDB (linked ke change ticket).
