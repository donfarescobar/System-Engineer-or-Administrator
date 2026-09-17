# Standar Server & Compute

## 1. Klasifikasi Environment
| Environment | Tujuan | Isolasi | Akses |
|---|---|---|---|
| DEV | Pengembangan fitur | Terpisah penuh dari data produksi | Tim developer |
| SIT/UAT | Integrasi & user acceptance test | Data disamarkan (masked) dari produksi | Developer + QA + business user |
| STAGING | Replika mendekati produksi untuk rehearsal rilis | Sama spesifikasi dengan prod (skala lebih kecil) | Release manager, SRE |
| PRODUCTION | Layanan nyata ke nasabah | Zona restricted, akses PAM only | Terbatas, on-call only |
| DR | Standby untuk kontinuitas | Mirror produksi | Sama seperti produksi saat failover |

**Aturan wajib**: data produksi (termasuk PII nasabah) tidak boleh disalin mentah ke DEV/SIT tanpa proses masking/anonymisasi (sesuai UU PDP & ketentuan OJK).

## 2. Provisioning Server
- Seluruh provisioning via IaC (Terraform/Ansible) — dari template yang direview & disetujui security team.
- Tidak ada server yang dibuat manual di production ("no snowflake server" policy); jika ditemukan, ditandai sebagai temuan audit.
- Setiap server baru otomatis terdaftar ke: CMDB, monitoring agent, log forwarder, backup agent, vulnerability scanner — sebagai bagian dari provisioning pipeline (bukan langkah manual terpisah).

## 3. Baseline OS
- OS yang didukung vendor resmi (mis. RHEL/Oracle Linux untuk core, Ubuntu LTS untuk service pendukung) — tidak menggunakan versi EOL.
- Baseline hardening mengikuti CIS Benchmark level 1/2 sesuai kekritisan sistem (lihat `hardening-baseline.md`).
- Automatic security update untuk patch non-disruptif; patch mayor melalui change management.

## 4. High Availability per Tier
| Tier | Skema HA | Failover Time Target |
|---|---|---|
| Load Balancer | Active-Active pair | < 5 detik |
| App/Service | Multi-replica (min. 3 pod/instance lintas AZ/rack) | Tanpa downtime (rolling) |
| Message Broker | Cluster multi-broker, replication factor ≥ 3 | Otomatis, tanpa data loss (acks=all) |
| Database Core | Cluster + synchronous replica DR | ≤ 5 menit (manual/otomatis terkontrol) |
| DNS/Service Discovery | Multi-node, anycast (jika ada) | < 5 detik |

## 5. Lifecycle Otomasi
- **CI/CD driven deployment** — deployment ke production tidak dilakukan manual login ke server (lihat `docs/cicd/cicd-pipeline.md`).
- **Immutable Server**: patch dilakukan dengan replace instance/pod baru, bukan in-place upgrade pada production.
- **Decommissioning**: checklist wajib — hapus dari monitoring, cabut secret/credential terkait, wipe data sesuai standar (mis. NIST 800-88) sebelum hardware di-retire/dijual/didaur ulang.
