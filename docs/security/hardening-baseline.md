# Baseline Hardening Sistem

## 1. Acuan
Mengikuti **CIS Benchmark** (level 1 untuk umum, level 2 untuk sistem kritikal/core banking) dan rekomendasi vendor OS/aplikasi, disesuaikan dengan kebutuhan operasional.

## 2. Hardening Level OS (Linux, contoh)
- Disable service/daemon yang tidak digunakan (mis. telnet, FTP plaintext, rlogin).
- SSH: disable root login langsung, gunakan key-based auth, port non-default (opsional, defense-in-depth bukan pengganti kontrol utama), enforce MFA untuk akses interaktif.
- Filesystem: partisi terpisah untuk `/var`, `/tmp`, `/log` dengan opsi mount `noexec,nosuid` di mana relevan.
- Kernel hardening: parameter sysctl (mis. disable IP forwarding jika bukan router, ASLR aktif, disable core dump untuk proses sensitif).
- Audit logging: `auditd` aktif merekam perubahan file konfigurasi kritikal, eksekusi command privileged.
- Automatic lock account setelah percobaan login gagal berulang (mis. 5x → lock sementara).

## 3. Hardening Database
- Disable akun default/sample (mis. akun demo bawaan vendor).
- Enkripsi TDE (Transparent Data Encryption) aktif untuk tablespace berisi data sensitif.
- Audit trail level row untuk tabel finansial kritikal (siapa mengubah apa, kapan).
- Least privilege: aplikasi connect dengan akun service terbatas (tidak pernah pakai akun DBA/sysdba untuk operasional harian).
- Network: database tidak listen di interface publik, hanya di segmen restricted.

## 4. Hardening Container/Kubernetes
- Base image minimal (distroless/slim), tanpa shell/tool debugging di image production.
- Pod Security Standards: `restricted` profile — no privileged container, no host network/PID namespace sharing, read-only root filesystem di mana memungkinkan.
- Network Policy default-deny antar-namespace, whitelist eksplisit komunikasi antar service.
- Image scanning wajib lulus (tanpa critical/high vulnerability) sebelum masuk registry production.
- Admission controller (mis. OPA/Gatekeeper) menolak deployment yang tidak memenuhi baseline (mis. tanpa resource limit, tanpa label wajib).

## 5. Hardening Aplikasi Web
- Header keamanan wajib: `Strict-Transport-Security`, `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options`.
- Input validation & output encoding untuk mencegah injection (SQLi, XSS).
- Session management: token pendek umur, invalidasi saat logout, deteksi & blokir session hijacking (binding ke device fingerprint/IP pattern).
- Rate limiting & CAPTCHA pada endpoint sensitif (login, reset password, OTP request).

## 6. Verifikasi & Compliance Scanning
- Compliance scanning otomatis terhadap CIS Benchmark berjalan berkala (mis. via OpenSCAP/vendor tool), hasil dilaporkan sebagai skor kepatuhan per server/cluster.
- Deviasi dari baseline wajib punya justifikasi terdokumentasi (exception register) dan compensating control, ditinjau saat audit.

## 7. Golden Image Lifecycle
1. Base OS image di-hardening sesuai baseline.
2. Image di-scan (vulnerability + compliance) → hanya lolos jika tidak ada critical finding.
3. Image disimpan di registry ter-versi, digunakan sebagai satu-satunya sumber provisioning (IaC pipeline).
4. Rebuild image berkala (mis. bulanan) untuk memasukkan patch terbaru — bukan patch manual di atas image lama.
