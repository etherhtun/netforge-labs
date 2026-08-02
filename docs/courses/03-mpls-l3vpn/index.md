# Course 3 — MPLS & L3VPN

> ⚠️ **Status: in development.** Lab 01 below is validated live. The L3VPN labs and
> the teaching sessions are still being built.

MPLS is how service providers move traffic without every router in the middle
needing to know where anything is. Instead of looking up a destination at every
hop, routers swap a small fixed label — and the whole path is decided once, at the
edge.

**L3VPN** builds on that: many customers, each with their own private routing
table, all sharing one provider backbone, none able to see the others.

---

## What you'll build

| Lab | You build | Status |
|---|---|---|
| **01** | MPLS + LDP underlay — OSPF, label distribution, forwarding state | ✅ Validated |
| 02 | Minimal L3VPN — one VRF, VPNv4, CE-to-CE | 📋 Planned |
| 03 | Multi-tenant L3VPN — route targets, isolation between customers | 📋 Planned |
| 04 | Hub-and-spoke L3VPN | 📋 Planned |

---

## Prerequisites

- **[BGP Fundamentals](../../roadmap.md)** — L3VPN is MP-BGP with extra headers. If
  route reflectors and address families are unfamiliar, start there.
- A working lab environment — see **[macOS lab setup](../../getting-started/lab-setup-macos.md)**.

---

## Platform note

These labs run on **Arista cEOS**. Before committing to the course we tested
whether cEOS could actually do MPLS rather than just accept the configuration.
[Lab 01](lab-01-mpls-ldp.md) *is* that test, written up as a lab.

**What it proved:** LDP sessions establish, labels are distributed correctly, and
MPLS forwarding entries are programmed with resolved adjacencies.

**What is still open:** labelled *transit*. Lab 02's L3VPN is the conclusive test,
because there a label is mandatory rather than optional. The
[roadmap](../../roadmap.md) tracks the outcome.

We'd rather tell you that honestly than have you discover it three labs in.
