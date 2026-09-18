# Ansible: Hardening Baseline OS

Role referensi untuk menerapkan baseline hardening Linux, acuan pada
`docs/security/hardening-baseline.md`. Mendukung RHEL/Oracle Linux (guna core
banking yang biasa RHEL family) dan Ubuntu LTS (service pendukung).

## Yang dilakukan role

- Update paket (opsional, via `hardening_update_packages`) sesuai jadwal patch.
- Konfigurasi sshd: root login tidak, password auth tidak, key-only, batasan
  `MaxAuthTries`, `X11Forwarding` nonaktif.
- Parameter kernel via `/etc/sysctl.d/99-hardening.conf`: IP forwarding 0,
  redirect off, `syncookies` on, ASLR aktif, `suid_dumpable` 0.
- Aktifkan `auditd` (audit logging untuk investigasi & compliance).
- Nonaktifkan layanan tidak terpakai (`telnet.socket`, `rlogin`, `rsh`, `ftp`,
  `rpcbind`) — hanya unit yang terpasang.
- Sinkronisasi waktu via chrony (wajib untuk korelasi log & non-repudiation).

Satu hal yang sengaja **tidak** saya automasikan di role ini: lockout akun via
PAM (`pam_faillock`). Alasannya konfigurasi PAM sangat tergantung distro dan
versi, dan salah terapkan bisa mengunci seluruh akses administratif di
production. Ini titik yang justru harus divertifikasi manual per OS terlebih
dahulu sebelum dibakukan — keputusan sadar yang saya ambil (lihat
`SKILL.md` §3).

## Cara menjalankan

```bash
# syntax check (juga dijalankan pada CI)
ansible-playbook -i inventory/example.ini --syntax-check hardening-playbook.yml

# eksekusi ke environment nyata — lewat pipeline/Ansible Tower, bukan manual
ansible-playbook -i inventory/<env>.ini hardening-playbook.yml
```

## Struktur

```
ansible/
├── ansible.cfg                  # konfigurasi ansible lokal
├── hardening-playbook.yml       # entry point
├── inventory/example.ini        # inventory ilustratif (host 10.10.x.x placeholder)
├── group_vars/                  # nilai override per environment
└── roles/hardening_os/
    ├── defaults/                # nilai default role
    ├── vars/                    # daftar service/sysctl yang diterapkan
    ├── tasks/                   # task hardening
    ├── handlers/
    └── templates/
```

## Catatan

- Inventory `example.ini` hanya ilustratif; jangan commit inventory asli
  dengan IP/host produksi ke repo publik.
- Kredensial diambil dari ansible-vault / secret manager pada eksekusi nyata —
  tidak pernah ditulis di inventory.
- Validasi perubahan di CI (`make ansible-check`), bukan mengandalkan koneksi
  ke server.