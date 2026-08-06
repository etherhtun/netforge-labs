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

## Course Matrix & Labs

| Lab | Description | Core Protocols & Concepts | Status |
|---|---|---|---|
| **[01](lab-01-vxlan-evpn.md)** | VXLAN-EVPN Datacenter Fabric & Symmetric IRB | OSPF underlay, iBGP EVPN RRs, Symmetric IRB, Anycast Gateway | 🟢 **Validated** |
| **[02](lab-02-esi-multihoming.md)** | EVPN ESI All-Active Multihoming | ESI `0001:0001:0001...`, Route Types 1 & 4, DF Election, Split Horizon | 🟢 **Validated** |
| **[03](lab-03-evpn-vpws-elan.md)** | EVPN-VPWS (E-LINE) & EVPN-ELAN | Point-to-Point Pseudowire, E-LAN Headend Replication, Route Types 2 & 3 | 🟢 **Validated** |
| **[04](lab-04-evpn-dci-multisite.md)** | VXLAN-EVPN DCI & Multi-Site | Border Gateways, Multi-Site EVPN, Inter-Site VXLAN Re-encapsulation | 🟢 **Validated** |

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
