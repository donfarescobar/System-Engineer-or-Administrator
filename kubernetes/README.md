# Kubernetes: Digital Channel Tier

Manifest referensi untuk tier channel digital berjalan pada cluster Kubernetes.
Acuan desain: `docs/architecture/system-architecture.md`, `docs/architecture/application-architecture.md`, dan `docs/security/hardening-baseline.md`.

## Prinsip yang diterapkan

- **Pod Security Standards `restricted`** di level namespace (bukan per-deployment), via label PSA.
- **Default-deny egress & ingress** di level namespace (`base/02-networkpolicy-default-deny.yaml`); komunikasi antar-service harus diizinkan eksplisit per NetworkPolicy.
- **Service dijalankan non-root**, root filesystem read-only, semua capability di-drop, probe kesehatan wajib.
- **Anti-affinitas antar-pod** agar replica tersebar antar zone/rack (lihat `docs/infrastructure/high-availability-design.md`).
- Image dari registry internal (`registry.example.local/...`) — gambar placeholder, bukan image publik.

## Struktur

```
digital-channel/
├── base/            # Namespace + PodSecurity + NetworkPolicy default-deny
└── services/
    ├── auth-service/            # login/token (OIDC), pola REST
    └── transfer-orchestrator/   # orkestrasi transfer, pola event (Kafka)
```

## Cara apply (urutan penting)

```bash
# 1. Basis: namespace + kebijakan default-deny dulu, bukan terbalik.
kubectl apply -f kubernetes/digital-channel/base/

# 2. Lalu service per service.
kubectl apply -f kubernetes/digital-channel/services/
```

## Catatan

- Namespace `messaging` (Kafka broker) dan `dmz` dirujuk pada aturan egress — keduanya dikelola sebagai bagian dari tier middleware/edge yang berada di luar direktori ini.
- Nilai `runAsUser: 65532` adalah akun non-root generik container; pada produksi sesuaikan dengan distroless image masing-masing service.
- Contoh di sini sengaja tanpa Ingress resource: traffic publik masuk lewat DMZ/WAF → service, sesuai zonasi `network-architecture.md`.