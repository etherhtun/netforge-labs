# 🌐 Phase 6 · Enterprise WAN Edge & Dual-ISP Multihoming

> 🚀 **100% Local Enterprise Architecture Masterclass**: From Dual-ISP eBGP multihoming and BGP traffic engineering (AS-PATH prepending & communities) to sub-second BFD failover and local RPKI Route Origin Validation (ROV).

---

## 🏛️ Course Architecture & WAN Edge Roadmap

Connecting enterprise infrastructure to the public Internet requires resilient, multihomed eBGP connections across multiple Internet Service Providers (ISPs). Phase 6 teaches you how to design, peer, and engineer traffic across **100% local, self-contained containerlab topologies**:

```
Phase 6 · Enterprise WAN Edge & Dual-ISP Multihoming
├── 🧪 Lab 01 · Active/Standby & Active/Active Dual-ISP eBGP Multihoming
├── 🧪 Lab 02 · Inbound & Outbound BGP Traffic Engineering (AS-PATH & Communities)
├── 🧪 Lab 03 · Sub-Second WAN Link Failover with BFD
└── 🧪 Lab 04 · Local RPKI Route Origin Validation (ROV) Simulation
```

---

## 🧠 Enterprise WAN Edge Design Principles

| Architecture Challenge | Production Engineering Solution |
|---|---|
| Single ISP link failure causes total blackout | **Multihomed eBGP to Dual ISPs** (Primary `ASN 65100` / Backup `ASN 65200`) |
| Uncontrolled asymmetric inbound traffic | **AS-PATH Prepending** & **BGP Community tagging** |
| Slow 180s BGP hold-timer link failure detection | **Sub-Second BFD (Bidirectional Forwarding Detection)** |
| BGP Route Hijacking vulnerability | **Local RPKI Route Origin Validation (ROV)** |
