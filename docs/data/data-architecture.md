# Arsitektur Data (Data Architecture)

## 1. Prinsip Pengelolaan Data
1. **Single Source of Truth** — setiap entitas data (nasabah, rekening, transaksi) punya satu sistem otoritatif (system of record), sistem lain mengambil salinan/turunan yang jelas asalnya (lineage).
2. **Konsistensi Kuat untuk Data Finansial** — saldo & posting ledger menggunakan transaksi ACID, bukan eventual consistency.
3. **Konsistensi Eventual Diterima untuk Data Non-Kritikal** — dashboard analitik, laporan agregat, notifikasi boleh eventual consistency demi skalabilitas.
4. **Data Lineage & Traceability** — setiap transformasi data (ETL/ELT) tercatat, dapat ditelusuri dari sumber hingga laporan akhir (penting untuk audit regulasi).

## 2. Alur Data (Data Flow)

```
[Core Banking / OLTP]  --CDC (Change Data Capture)-->  [Event Bus / Kafka]
        │                                                       │
        │ (batch EOD)                                           ▼
        ▼                                              [Stream Processing]
[Data Warehouse / ODS]  <----------- batch load ------  (enrichment, agregasi)
        │
        ▼
[BI/Reporting Layer] ---> [Laporan Regulasi (OJK/BI)] & [Dashboard Manajemen]
```

## 3. Klasifikasi Data
| Kelas | Contoh | Kontrol |
|---|---|---|
| Kritikal Finansial | Saldo, mutasi ledger, posting jurnal | ACID, audit trail penuh, WORM log |
| Sensitif Pribadi (PII) | NIK, nomor HP, alamat, nomor kartu | Enkripsi, masking non-prod, kontrol akses ketat |
| Operasional | Log aplikasi, metrik performa | Retensi sesuai kebutuhan operasional |
| Analitik/Agregat | Data warehouse, hasil agregasi | Anonymized/pseudonymized bila memungkinkan |
| Publik | Suku bunga, produk, lokasi cabang | Tanpa kontrol khusus |

## 4. Data Governance
- **Data Owner** ditetapkan per domain data (mis. domain "Nasabah" dimiliki unit CRM/Retail Banking), bertanggung jawab atas kualitas & kebijakan akses.
- **Data Steward** menjalankan kebijakan harian (validasi kualitas data, penanganan permintaan akses).
- **Data Dictionary** terpusat — definisi field, tipe data, unit, dan aturan bisnis terdokumentasi agar konsisten lintas sistem.
- **Master Data Management (MDM)** untuk entitas inti (nasabah, produk) guna menghindari duplikasi/inkonsistensi antar sistem channel.

## 5. Kualitas Data
- Validasi di titik masuk (input validation) — mencegah data kotor masuk ke sistem hulu.
- Reconciliation job harian (End of Day) mencocokkan saldo antar sistem (core banking vs payment switching vs data warehouse) — selisih di luar toleransi memicu alert investigasi.
- Data quality metrics (completeness, accuracy, timeliness) dipantau dan dilaporkan berkala ke data governance committee.

## 6. Analitik & Machine Learning (jika relevan)
- Feature store terpisah dari data produksi untuk model fraud detection/credit scoring, dengan proses refresh terjadwal.
- Model yang mempengaruhi keputusan nasabah (mis. credit scoring) melalui proses validasi model risk management (model governance), tidak langsung deploy dari eksperimen data scientist.
