# Phase 4 — EVPN Services

> ✅ **Lab 01 validated** on Arista cEOS 4.32.0F. The remaining services are being
> built.

Traditional data-centre networks stretched VLANs by physically extending layer 2 —
which meant spanning tree, broadcast domains that spanned buildings, and a single
misbehaving host taking out a floor.

**VXLAN-EVPN** replaces that with an overlay: layer 2 rides inside UDP over a
perfectly ordinary routed network, and BGP distributes MAC addresses instead of
flooding to discover them.

---

## What you'll build

| Lab | You build | Status |
|---|---|---|
| **01** | VXLAN-EVPN fabric — OSPF underlay, iBGP-EVPN with route reflectors, L2VNI | ✅ Validated |
| 02 | EVPN-ELAN — multipoint layer 2, the modern replacement for VPLS | 📋 Planned |
| 03 | EVPN-VPWS — point-to-point pseudowire | 📋 Planned |
| 04 | VXLAN-EVPN DCI — stretching EVPN between two fabrics | 📋 Planned |

---

## Prerequisites

- **[Phase 0 · IGP Fundamentals](../00-igp-fundamentals/index.md)** — the underlay
  has to work before any overlay can. This is not optional advice.
- **BGP familiarity** — EVPN is a BGP address family. Route reflectors and address
  families should not be new.
- A working lab environment — see
  **[lab setup](../../getting-started/lab-setup-macos.md)**.

---

## The concepts

Short primers, readable in about five minutes each, plus an interview bank:

[Start with the concepts →](concepts/index.md)

They stand alone, so you can read them before the lab or use them as a reference
while working through it.

---

## Also available: the Juniper track

The same subject built on Juniper vJunos-switch — ten sessions and five lab guides
— is kept as a
**[reading archive](../../archive/juniper-vxlan-evpn/index.md)**. The theory is
platform-agnostic and worth reading; the labs need a cloud VM, which is why the
hands-on path moved to cEOS.
