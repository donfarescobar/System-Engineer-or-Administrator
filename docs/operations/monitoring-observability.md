# Monitoring & Observability

## 1. Tiga Pilar Observability
1. **Metrics** — data numerik time-series (CPU, latency, throughput, error rate, saldo antrian).
2. **Logs** — catatan event terstruktur (aplikasi, sistem, audit).
3. **Traces** — jejak request lintas service (distributed tracing) untuk debugging latency/error di arsitektur microservices.

## 2. Stack Referensi
| Fungsi | Tool Referensi |
|---|---|
| Metrics collection & alerting | Prometheus + Alertmanager |
| Visualisasi | Grafana |
| Log aggregation | ELK Stack (Elasticsearch/Logstash/Kibana) atau Loki |
| Distributed tracing | Jaeger/Tempo (OpenTelemetry standard) |
| SIEM (security-focused) | Splunk/QRadar/Elastic Security |
| Synthetic monitoring | Uptime check dari luar (mengukur dari sudut pandang nasabah) |

## 3. Golden Signals (per Service)
- **Latency**: waktu respons (p50, p95, p99) — bukan hanya rata-rata.
- **Traffic**: volume request per detik.
- **Errors**: rate error (4xx/5xx, error bisnis seperti transaksi gagal).
- **Saturation**: seberapa penuh resource (CPU, memori, connection pool, queue depth).

## 4. Dashboard Wajib per Sistem Kritikal
1. **Dashboard Kesehatan Layanan** — status up/down, latency, error rate real-time.
2. **Dashboard Kapasitas** — utilisasi resource, tren pertumbuhan, proyeksi kapan mencapai threshold.
3. **Dashboard Transaksi Bisnis** — volume transaksi, nilai transaksi, tingkat keberhasilan (bukan hanya metrik teknis, tapi metrik bisnis yang dipahami stakeholder non-teknis).
4. **Dashboard Keamanan** — percobaan login gagal, anomali akses privileged, alert IDS/IPS.

## 5. Kebijakan Alerting
- **Alert harus actionable** — setiap alert yang masuk ke on-call wajib punya runbook terkait; alert yang tidak actionable ("alert fatigue") harus di-tune ulang atau dihapus.
- **Severity tiering**:
  - Sev1 (Critical): layanan nasabah terdampak signifikan → paging langsung, respons < 15 menit.
  - Sev2 (High): degradasi parsial → notifikasi tim on-call, respons < 1 jam.
  - Sev3 (Medium): tidak berdampak langsung, perlu tindak lanjut → tiket, respons dalam jam kerja.
  - Sev4 (Low/Info): informasi, tidak perlu tindakan segera.
- Eskalasi otomatis (mis. via pager/on-call rotation tool) jika alert Sev1/Sev2 tidak di-acknowledge dalam waktu tertentu.

## 6. Retensi Data Observability
- Metrics: resolusi tinggi (mis. 15 detik) untuk 7–30 hari, downsampled untuk retensi jangka panjang (analisis tren).
- Logs aplikasi: sesuai kebijakan retensi masing-masing (lihat `data-classification-retention.md`); log audit/transaksi finansial mengikuti retensi regulasi.
- Traces: retensi lebih pendek (mis. 7–14 hari) karena volume besar, kecuali trace terkait insiden yang diarsipkan khusus.

## 7. Observability sebagai Bagian dari Definition of Done
Setiap service baru sebelum ke production wajib memiliki:
- Dashboard dasar (golden signals).
- Alert minimum (availability, error rate, latency).
- Structured logging dengan correlation ID (agar bisa ditelusuri lintas service).
- Instrumentasi tracing (OpenTelemetry SDK terpasang).
