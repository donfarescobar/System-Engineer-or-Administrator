# Banking & Enterprise Infrastructure — Portofolio Donfar

Saya Donfar, system/infrastructure engineer yang sebagian besar karirnya
berada di sisi lingkungan critical system dan regulasi yang ketat. Repo ini
berisi bagaimana saya merancang, mengamankan, dan mengoperasikan infrastruktur
perbankan berskala menengah-besar: dari keputusan arsitektur yang paling atas
sampai runbook yang dipakai on-call di malam hari.

Sebelum lanjut, satu catatan penting: **ini bukan dokumentasi bank sungguhan**.
Ini referensi desain yang saya susun sendiri berdasarkan pengalaman dan standar
industri (OJK/BI, ISO 27001, PCI-DSS, NIST), dan saya sengaja menuliskan
alasan serta trade-off di setiap keputusan — bukan sekadar diagram yang bagus
dilihat. Kalau kalian pernah bekerja di sektor ini, pola-pola di repo ini
pasti terasa familiar.

## Kenapa bentuknya begini

Dari pengalaman saya, hal tersulit untuk diturunkan ke engineer baru bukanlah
cara menjalankan perintah, tapi *alasan* sebuah keputusan diambil. Contoh
sederhana:

- kenapa core banking tidak dipindahkan ke public cloud padahal biayanya lebih
  murah,
- kenapa setiap komunikasi antar-service tetap diwajibkan mTLS padahal sudah
  ada VPN,
- kenapa failover database primer justru tidak dibiarkan otomatis penuh.

Dokumen di `docs/` ditulis dengan pola seperti itu: setiap keputusan diikuti
alasannya, trade-off-nya, dan skenario kegagalan yang diantisipasi. Sementara
direktori `terraform/`, `ansible/`, `kubernetes/`, dan `cicd/` berisi
implementasi referensi dari desain tersebut, jadi apa yang didesain bisa
langsung dibayangkan bentuk aslinya. Keduanya saling melengkapi: dokumen
menjelaskan *kenapa*, kode menjelaskan *bagaimana*.

## Isi repo

```
banking-enterprise-portfolio/
├── README.md                  # index (file ini)
├── SKILL.md                   # kompetensi & justifikasi keputusan teknis
├── AGENTS.md                  # instruksi untuk AI agent yang melanjutkan proyek
├── docs/                      # dokumentasi desain (reference architecture)
│   ├── architecture/          #   system, network, application
│   ├── infrastructure/        #   standar compute, HA
│   ├── security/              #   compliance, IAM, hardening
│   ├── data/                  #   arsitektur & klasifikasi data
│   ├── disaster-recovery/     #   DR/BCP, backup-restore
│   ├── operations/            #   runbook, incident, change, observability
│   └── cicd/                  #   alur pipeline
├── terraform/                 # reference IaC: zonasi jaringan cloud tier
├── ansible/                   # role hardening baseline OS Linux
├── kubernetes/                # manifest digital channel (PSA restricted, netpol)
├── cicd/                      # penjelasan pipeline + referensi workflow
├── envs/                      # nilai per environment (tfvars ilustratif)
├── .github/workflows/         # pipeline CI/CD (GitHub Actions)
└── Makefile                   # validasi & lint lokal
```

## Dokumentasi dan implementasi

| Bagian | Dokumentasi | Implementasi referensi |
|---|---|---|
| Arsitektur & zonasi jaringan | `docs/architecture/*` | `terraform/` (subnet, routing, firewall rule per zona) |
| Keamanan sistem | `docs/security/*` | `ansible/` (hardening OS), `kubernetes/` (PSA restricted, network policy default-deny) |
| HA & deployment | `docs/infrastructure/*`, `docs/cicd/*` | `cicd/`, `.github/workflows/` (gate keamanan, approval, state locking) |

Detail cakupan dan asumsi tiap implementasi ada di README masing-masing
direktori (`terraform/README.md`, `ansible/README.md`, dst).

## Beberapa keputusan yang saya pegang teguh

- **Core banking tetap on-premise.** Iya, cloud lebih murah dan lebih elastis.
  Tapi data residency dan kontrol audit fisik untuk sistem ledger tidak bisa
  ditawar di regulasi perbankan Indonesia. Di repo ini, hal itu saya putuskan
  sejak awal (lihat `docs/architecture/system-architecture.md`, ADR-01) dan
  konsekuensinya konsisten di semua dokumen lain.
- **Ledger itu ACID, bukan eventual consistency.** Saldo nasabah tidak boleh
  "sama nanti-nanti ya". Setiap operasi finansial diposting dengan strong
  consistency; integrasi antar-service memakai pola outbox dan saga agar
  kegagalan parsial tidak pernah membuat saldo kepotong dua kali.
- **Zero trust di dalam jaringan, bukan hanya di perimeter.** Semua
  komunikasi service-to-service pakai mTLS. Di Kubernetes, default-nya deny:
  tidak ada pod yang bisa bicara ke pod lain kecuali diizinkan eksplisit.
- **Tidak ada deployment manual ke production.** SSH ke server produksi untuk
  install sesuatu sudah saya anggap insiden (atau setidaknya pelanggaran
  proses). Semua perubahan lewat pipeline yang tercatat: siapa, kapan, commit
  mana, hasil test apa.
- **Backup yang tidak pernah di-ujirestore sama saja tidak ada.** Jadwal
  restore test terjadwal dan terdokumentasi, bukan asumsi "yang penting sudah
  di-backup".

## Cara memvalidasi repo ini

Semua artifact di repo ini lolos check yang bisa dijalankan lokal maupun di CI:

```bash
make validate          # yamllint + terraform fmt/init/validate + ansible syntax check
```

Pipeline CI (`.github/workflows/ci.yml`) menjalankan hal yang sama plus scan
keamanan: gitleaks (secret), checkov & trivy (IaC), dan kubeconform (skema
manifest). Untuk deployment Terraform, ada jalur CD terpisah dengan approval
gate via GitHub Environment (`cd-iac.yml`).

## Roadmap

- Migrasi manifest Kubernetes ke Helm chart + policy OPA/Gatekeeper.
- Traffic generation & game day script untuk menguji asumsi HA/DR berkala
  (chaos engineering).
- Referensi provisi untuk provider cloud/usecase lain yang memenuhi syarat
  data residency, dengan modul Terraform yang reusable.
- Penambahan pipeline image build + signing (cosign) begitu ada codebase
  aplikasi service sungguhan.

## Catatan

- Angka seperti CIDR, RTO/RPO, dan harga bersifat ilustratif dan saya tulis
  sebagai asumsi eksplisit di tiap dokumen terkait.
- Implementasi `terraform/` memakai provider AWS untuk mewakili tier yang
  memang boleh di cloud (digital channel & analytics). Bagian core banking
  sengaja tidak ada di kode, karena memang tidak seharusnya di sana.

## Kontak

GitHub: [donfarescobar](https://github.com/donfarescobar)