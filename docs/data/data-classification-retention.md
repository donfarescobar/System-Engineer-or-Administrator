# Klasifikasi & Retensi Data

## 1. Skema Klasifikasi
| Level | Label | Deskripsi | Contoh |
|---|---|---|---|
| L1 | Public | Boleh diakses siapa saja | Info produk, suku bunga publik |
| L2 | Internal | Hanya untuk karyawan | SOP internal, dokumen non-sensitif |
| L3 | Confidential | Berdampak bila bocor, akses terbatas fungsi | Data transaksi agregat, laporan internal |
| L4 | Restricted/Highly Confidential | Berdampak besar bila bocor, akses sangat terbatas | PII nasabah, data kartu, kredensial, kunci enkripsi |

## 2. Kebijakan Retensi (Ilustratif, sesuaikan regulasi terkini)
| Jenis Data | Retensi Minimum | Media | Catatan |
|---|---|---|---|
| Log transaksi finansial | 10 tahun | WORM storage | Sesuai ketentuan dokumentasi perbankan |
| Log audit akses privileged | 5–10 tahun | WORM/immutable | Untuk investigasi & audit |
| Data transaksi nasabah (mutasi) | Sesuai ketentuan OJK yang berlaku | Storage tier archive terenkripsi | Dapat diakses untuk keperluan sengketa/audit |
| Log aplikasi umum (non-finansial) | 90–365 hari | Log storage standar | Rolling retention, sebagian diarsipkan |
| Rekaman sesi PAM (privileged session) | 1–3 tahun | Encrypted storage | Untuk investigasi insiden |
| Data pribadi setelah penutupan rekening | Sesuai ketentuan hukum yang berlaku + kebijakan internal | Terenkripsi, akses dibatasi | Hak hapus mengikuti UU PDP dengan pengecualian kewajiban hukum penyimpanan |

## 3. Prinsip Retensi
- **Retensi minimum untuk kepatuhan hukum**, bukan retensi maksimal "just in case" — data yang tidak lagi diperlukan dan telah melewati kewajiban retensi wajib dihapus/dianonimkan (data minimization, prinsip UU PDP).
- Proses penghapusan data terjadwal & terverifikasi (bukan manual ad-hoc), dengan log bukti penghapusan untuk audit.
- Jika data harus dimusnahkan dari media fisik (disk lama, backup tape), mengikuti standar sanitasi data (mis. NIST SP 800-88) dengan berita acara pemusnahan.

## 4. Penanganan Permintaan Subjek Data (Data Subject Request)
- Prosedur baku untuk permintaan nasabah terkait data pribadinya (akses, koreksi, penghapusan) sesuai UU PDP, dengan SLA respons yang jelas.
- Setiap permintaan diverifikasi identitas terlebih dahulu sebelum diproses, untuk mencegah penyalahgunaan (social engineering).

## 5. Cross-Border Data Transfer (jika ada)
- Jika ada transfer data ke luar negeri (mis. layanan cloud vendor asing untuk analitik non-sensitif), wajib melalui kajian kepatuhan (data residency requirement perbankan) dan persetujuan sesuai ketentuan yang berlaku, dengan kontrak yang menjamin standar perlindungan setara.
