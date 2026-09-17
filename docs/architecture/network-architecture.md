# Arsitektur Jaringan (Network Architecture)

## 1. Tujuan
Mendefinisikan segmentasi jaringan, topologi, dan kontrol keamanan level network untuk lingkungan perbankan yang comply terhadap prinsip zero trust dan defense in depth.

## 2. Segmentasi Zona (Network Zoning)

| Zona | Fungsi | Contoh Subnet (ilustratif) | Akses Masuk | Akses Keluar |
|---|---|---|---|---|
| Internet Edge | Titik masuk publik | N/A (ISP link, dual-homed) | Anti-DDoS scrubbing | — |
| DMZ | WAF, reverse proxy, load balancer publik | 10.10.1.0/24 | Dari internet edge via FW | Hanya ke API Gateway zone |
| API/App Zone | API Gateway, digital channel services | 10.10.10.0/23 | Dari DMZ via FW L7 | Ke Middleware zone saja |
| Middleware Zone | ESB, message broker, orchestration | 10.10.20.0/24 | Dari App zone | Ke Core zone (whitelisted port) |
| Core/Restricted Zone | Core banking, ledger, DB primer | 10.10.30.0/25 | Hanya dari Middleware + Jump server | Tidak ada rute langsung ke internet |
| Management/OOB | Monitoring, jump server, PAM, backup agent | 10.10.99.0/24 | VPN + MFA only | Terbatas, logged |
| DR Site | Replika seluruh zona di atas | Mirror subnet berbeda site | Direct link (dark fiber/MPLS) | Sesuai kebijakan replikasi |

## 3. Topologi Fisik & Redundansi

- **Dual ISP** dengan BGP failover (aktif-aktif untuk beban ringan, failover otomatis untuk backbone kritikal).
- **Core switch**: pasangan redundant (MLAG/VSS) di setiap layer (access, distribution, core) — tidak ada single point of failure.
- **Firewall**: HA pair (active-passive atau active-active cluster) di setiap boundary zona.
- **Load Balancer**: HA pair, health-check aktif ke seluruh backend, dengan circuit breaker.
- **Interkoneksi DC-DRC**: minimal dua jalur independen (dark fiber + MPLS/VPN backup), sinkron untuk replikasi data.

## 4. Kontrol Keamanan Jaringan

1. **Micro-segmentation** — setiap zona dipisah firewall L3/L4, dengan aturan default-deny; hanya port/protokol spesifik yang di-whitelist (contoh: App→Middleware hanya port 9092 Kafka TLS).
2. **East-West Traffic Inspection** — traffic antar-zona internal tetap diinspeksi IPS/IDS, tidak hanya di edge.
3. **NAC (Network Access Control)** — perangkat yang connect ke jaringan internal (termasuk workstation staff) diverifikasi posture (patch level, AV) sebelum diberi akses penuh.
4. **DNS Security** — DNS internal terpisah dari resolver publik, DNSSEC untuk domain publik, DNS sinkhole untuk domain malicious yang terdeteksi threat intel.
5. **Network Time Protocol (NTP)** — sinkronisasi waktu terpusat (wajib untuk korelasi log forensik & non-repudiation transaksi).
6. **Out-of-Band Management** — akses konfigurasi perangkat jaringan/server melalui jalur terpisah dari data plane, mencegah lateral movement via management interface.

## 5. Kebijakan Firewall (Contoh Ringkas)

| No | Source Zone | Dest Zone | Port/Protokol | Aksi | Justifikasi |
|---|---|---|---|---|---|
| 1 | Internet | DMZ | 443/TCP | Allow | Akses publik ke WAF |
| 2 | DMZ | App Zone | 443/TCP (mTLS) | Allow | Forward request tervalidasi WAF |
| 3 | App Zone | Middleware Zone | 9093/TCP (Kafka TLS) | Allow | Publish event transaksi |
| 4 | Middleware Zone | Core Zone | 1521/TCP (DB, via service account) | Allow terbatas | Posting transaksi ke ledger |
| 5 | Any | Core Zone | Any (langsung dari App/Internet) | **Deny** | Core hanya boleh diakses via Middleware/Jump host |
| 6 | Management | All zones | 22/TCP, 3389/TCP (via bastion) | Allow terbatas + logged | Administrasi terpusat via PAM |
| 7 | Core Zone | Internet | Any | **Deny** | Mencegah data exfiltration langsung dari core |

## 6. Monitoring Jaringan
- **Flow monitoring** (NetFlow/sFlow) untuk deteksi anomali volumetrik (indikasi DDoS/data exfiltration).
- **IDS/IPS signature + behavioral** ditempatkan di setiap boundary zona kritikal.
- **Full packet capture** pada segmen core untuk keperluan forensik, retensi sesuai kebijakan (mis. 30–90 hari rolling).
