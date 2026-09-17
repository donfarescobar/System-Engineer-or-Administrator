# Manajemen Identitas & Akses (IAM)

## 1. Prinsip
- **Least Privilege**: setiap identitas (manusia/service) hanya mendapat akses minimum yang diperlukan untuk fungsinya.
- **Zero Standing Privilege** untuk akses sensitif — akses privileged bersifat just-in-time (JIT), diberikan sementara dengan approval, bukan permanen.
- **Segregation of Duties**: peran administratif dipisah dari peran approval (mis. yang membuat user tidak boleh juga yang menyetujui).

## 2. Model Peran (RBAC)
| Peran | Contoh Hak Akses | Catatan |
|---|---|---|
| Developer | Akses repo, environment DEV/SIT | Tidak ada akses produksi |
| Release Engineer/SRE | Trigger deployment via pipeline, read-only monitoring prod | Tidak edit kode langsung |
| DBA | Akses database sesuai scope, melalui PAM + approval | Akses dicatat & direview |
| Security Analyst (SOC) | Akses SIEM, log, tools investigasi | Read-only ke sistem produksi |
| System Administrator | Konfigurasi infrastruktur via automation, akses OS via bastion/PAM | Sesi direkam |
| Business User (Ops Bank) | Akses aplikasi front-office sesuai fungsi (teller, CS) | RBAC granular per menu/transaksi |
| Auditor (Internal/Eksternal) | Read-only log & laporan | Tidak boleh mengubah data |

## 3. Autentikasi
- **MFA wajib** untuk seluruh akses administratif dan akses jarak jauh (VPN).
- **SSO berbasis SAML/OIDC** untuk aplikasi internal, terintegrasi dengan direktori terpusat (mis. Active Directory/LDAP).
- **Password policy**: minimum panjang & kompleksitas sesuai kebijakan internal, tidak reuse password lama, wajib ganti berkala untuk akun privileged.
- **Service-to-service auth**: mTLS + short-lived token (bukan static API key permanen) untuk komunikasi antar microservices.

## 4. Privileged Access Management (PAM)
- Seluruh akses privileged (root, DBA, network admin) melalui **jump server/bastion** yang direkam sesi penuh (session recording).
- **Just-in-Time Access**: permintaan akses privileged diajukan via tiket, disetujui atasan/security, akses otomatis dicabut setelah durasi tertentu (mis. 4–8 jam) atau setelah task selesai.
- **Break-glass procedure**: untuk kondisi darurat (mis. incident Sev1 di luar jam kerja), akses darurat diberikan dengan approval retroaktif dan audit wajib dalam 24 jam.
- Password vault (mis. CyberArk/Vault) untuk credential shared/service account — tidak ada shared password yang diketahui manusia secara langsung (dynamic secrets/checkout mechanism).

## 5. Provisioning & Deprovisioning
- Onboarding karyawan: akses diberikan berdasarkan role template (bukan copy dari user lain), disetujui manajer + pemilik sistem.
- Offboarding: seluruh akses dicabut **pada hari yang sama** dengan tanggal efektif keluar (integrasi HRIS → IAM otomatis, bukan proses manual berhari-hari).
- Mutasi jabatan: akses lama dicabut, akses baru diberikan sesuai role baru (tidak menumpuk akses/"access creep").

## 6. Review & Audit Akses
- **User Access Review (UAR)** triwulanan: pemilik sistem memverifikasi seluruh daftar user & hak aksesnya, akses yang tidak sesuai wajib dicabut.
- **Dormant account detection**: akun yang tidak aktif > 30–90 hari otomatis dinonaktifkan (disable, bukan langsung dihapus, untuk investigasi jika diperlukan).
- Log seluruh aktivitas privileged dikirim ke SIEM, dengan alert untuk pola anomali (mis. login di luar jam kerja, akses dari lokasi tidak biasa, banyak percobaan gagal).

## 7. Identity untuk Non-Human (Service Account & Machine Identity)
- Service account punya scope spesifik per aplikasi (bukan generik "svc_admin").
- Certificate/key rotation otomatis, masa berlaku pendek untuk mengurangi blast radius jika bocor.
- Inventarisasi seluruh service account & API key terpusat, dengan expiry tracking.
