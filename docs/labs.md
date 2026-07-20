# Labs

Each lab is a **complete, self-contained guide** — read it top to bottom (overview
→ every step → verify → break-it), all here in the portal. Each lab has its **own
independent fabric** (distinct container names), so they never conflict.

> **Run one lab at a time** — a 2×2 vJunos fabric needs ~16 GB RAM. To switch
> labs, wipe the current one first (`./scripts/destroy.sh <lab>`).

## Lab 01 — OSPF underlay + iBGP-EVPN (full mesh) ✅

The **foundational** lab (validated on vJunos-switch 23.2R1.14). The simplest
overlay — leaves peer directly — so you see EVPN in its clearest form. Fabric:
`clab-evpn-fullmesh-*`.

👉 **[Open the complete guide →](labs/lab-01-fullmesh.md)**

```bash
./scripts/deploy.sh 01-ospf-ibgp && ./scripts/apply.sh 01-ospf-ibgp all
```

## Lab 02 — OSPF underlay + iBGP-EVPN, spine route-reflectors ⭐ (production)

The **production** overlay: leaves peer only to the spines; spines reflect EVPN
routes (control-plane only — **not** VTEPs). Full-mesh (lab 01) doesn't scale
past a few leaves; this does. Fabric: `clab-evpn-rr-*`.

👉 **[Open the complete guide →](labs/lab-02-rr.md)**

```bash
./scripts/deploy.sh 02-ospf-ibgp-rr && ./scripts/apply.sh 02-ospf-ibgp-rr all
```

## Lab 03 — Anycast gateway + L3VNI (inter-subnet routing) ⚠️ draft

Adds a **second subnet** and routes between subnets across the fabric — an anycast
gateway on every leaf + a Layer-3 VNI (Type-5, symmetric IRB). Built on the
route-reflector fabric. Fabric: `clab-evpn-l3vni-*`.

👉 **[Open the complete guide →](labs/lab-03-l3vni.md)** *(config pending live validation)*

```bash
./scripts/deploy.sh 03-l3vni-anycast && ./scripts/apply.sh 03-l3vni-anycast all
```

## Lab 04 — Multi-tenancy (isolation + route leaking) ⚠️ draft

Two tenants on one fabric, isolated by route-target, then leaked on purpose.
Fabric: `clab-evpn-mt-*`.

👉 **[Open the complete guide →](labs/lab-04-multitenancy.md)** *(pending live validation)*

```bash
./scripts/deploy.sh 04-multitenancy && ./scripts/apply.sh 04-multitenancy all
```

## Planned

| Lab | Adds | Status |
|-----|------|--------|
| 05 | ESI multihoming (dual-homed hosts) | 📋 planned |
| 06 | eBGP underlay / eBGP-EVPN designs | 📋 planned |

Each will be a full self-contained guide like the ones above.

See the [Quickstart](quickstart/intro.md) for the team workflow.
