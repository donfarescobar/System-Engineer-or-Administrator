# Banking and Enterprise Infrastructure

This repository is a portfolio project by Donfar, a systems and infrastructure
engineer focused on critical platforms and regulated environments. It documents
how I design, secure, and operate a medium-to-large banking platform, from
architecture decisions to the runbooks used during production incidents.

This is not documentation for a real bank. It is an independent reference
architecture based on industry practices and standards, including OJK and BI
guidance, ISO 27001, PCI DSS, and NIST. The documents explain the reasoning,
constraints, and trade-offs behind each decision instead of presenting diagrams
without operational context.

## What this repository covers

The project combines design documentation with reference implementations:

```
banking-enterprise-portfolio/
├── docs/                      # Architecture, security, data, DR, and operations
├── terraform/                 # Network zones and security controls for cloud tiers
├── ansible/                   # Linux hardening baseline
├── kubernetes/                # Restricted digital-channel manifests and network policies
├── cicd/                      # CI/CD design and deployment guidance
├── envs/                      # Local environment values; secrets are not committed
├── .github/workflows/         # GitHub Actions pipelines
└── Makefile                   # Local validation targets
```

The documents describe why a control exists; the implementation directories
show one way to express that control in infrastructure code. Each directory
contains additional scope notes and assumptions where appropriate.

## Architecture principles

- **The core banking platform remains on-premises.** Ledger workloads require
  strict data residency, physical auditability, and tightly controlled access.
  The cloud reference implementation therefore covers only approved non-core
  tiers such as digital channels and analytics.
- **Financial data requires strong consistency.** Account balances and ledger
  postings use ACID semantics. Outbox and saga patterns handle cross-service
  delivery without introducing duplicate financial effects.
- **Trust is explicit inside the network.** Service-to-service communication
  uses mTLS, and Kubernetes namespaces start with default-deny network policies.
  Traffic is opened only through an explicit policy.
- **Production changes are delivered through a controlled pipeline.** Manual
  SSH-based deployment is outside the operating model. Changes must be reviewed,
  tested, approved, and traceable to a commit.
- **Backups are verified through restore tests.** A backup schedule is not a
  recovery strategy until restores have been tested and recorded.

## Repository map

| Area | Design references | Reference implementation |
|---|---|---|
| Architecture and network zoning | `docs/architecture/` | `terraform/` |
| Security and hardening | `docs/security/` | `ansible/`, `kubernetes/` |
| Availability and delivery | `docs/infrastructure/`, `docs/cicd/` | `cicd/`, `.github/workflows/` |
| Data and recovery | `docs/data/`, `docs/disaster-recovery/` | Policies and operational guidance |
| Operations | `docs/operations/` | Runbooks, monitoring, incident, and change guidance |

## Validate locally

Run the repository checks from the project root:

```bash
make validate
```

This runs YAML linting, Terraform formatting and validation, Ansible syntax
checking, and Kubernetes manifest linting. CI adds secret scanning and IaC
security checks with Gitleaks, Checkov, Trivy, and kubeconform. Terraform
deployment uses a separate workflow with an approval gate through GitHub
Environments.

## Assumptions and scope

CIDR ranges, recovery objectives, costs, and capacity figures are illustrative
and are documented as assumptions in the relevant design files. The Terraform
code uses AWS to represent cloud-eligible tiers; it intentionally does not
attempt to provision the core banking platform.

## Roadmap

- Move Kubernetes manifests to Helm with OPA/Gatekeeper policy enforcement.
- Add repeatable traffic-generation and HA/DR game-day exercises.
- Extend the Terraform reference for additional residency-compliant providers.
- Add image build and signing with Cosign when application services are added.

## Contact

GitHub: [donfarescobar](https://github.com/donfarescobar)