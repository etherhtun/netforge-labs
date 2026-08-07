# 🌐 Phase 9 · IPv6 Transition & Dual-Stack Infrastructure

> 🚀 **100% Local Enterprise & SP IPv6 Masterclass**: From IPv6 Neighbor Discovery (ND) and SLAAC to BGP Unnumbered over IPv6 Link-Local (RFC 5549 / RFC 8950), 6PE/6VPE over MPLS, and Stateful NAT64/DNS64 translation.

---

## 🏛️ Course Architecture & IPv6 Roadmap

Transitioning to IPv6-only data center underlays and dual-stack enterprise edges eliminates IPv4 address exhaustion, NAT friction, and operational overhead. Phase 9 teaches you how to build **100% local, self-contained IPv6 network architectures**:

```
Phase 9 · IPv6 Transition & Dual-Stack Infrastructure
├── 🧪 Lab 01 · IPv6 Neighbor Discovery (ND) & SLAAC / DHCPv6
├── 🧪 Lab 02 · BGP Unnumbered (BGP over IPv6 Link-Local RFC 5549)
├── 🧪 Lab 03 · 6PE & 6VPE (IPv6 Provider Edge over MPLS Backbones)
└── 🧪 Lab 04 · Stateful NAT64 & DNS64 Translation Mechanics
```

---

## 🧠 IPv6 Architecture & Transition Mechanics

| Architecture Challenge | Production Engineering Solution |
|---|---|
| IPv4 Address Exhaustion & NAT Overload | **IPv6 Global Unicast Addressing (`2001:db8::/32`)** |
| Subnetting Overhead on Point-to-Point Links | **BGP Unnumbered over IPv6 Link-Local (`fe80::/10`) (RFC 5549)** |
| IPv6 Transport Across Legacy IPv4 Core | **6PE (IPv6 Provider Edge over MPLS)** |
| IPv6-only Host Access to Legacy IPv4 Services | **Stateful NAT64 & DNS64 Translation (`64:ff9b::/96`)** |
