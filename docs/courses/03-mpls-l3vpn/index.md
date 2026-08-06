# Phase 3 — MPLS & L3VPN

> 🟢 **Phase 3 Live** — Validated on Arista cEOS 4.32.0F.

MPLS is how service providers move traffic without every router in the middle needing to know where anything is. Instead of looking up a destination at every hop, routers swap a small fixed label — and the whole path is decided once, at the edge.

**L3VPN (RFC 4364)** builds on that: many customers, each with their own private routing table (VRF), all sharing one provider backbone with complete isolation.

---

## Course Matrix & Labs

| Lab | Description | Core Protocols & Concepts | Status |
|---|---|---|---|
| **[01](lab-01-mpls-ldp.md)** | MPLS + LDP Underlay | OSPF, LDP Label Distribution, LFIB forwarding state | 🟢 **Validated** |
| **[02](lab-02-l3vpn-option-a.md)** | Single-AS L3VPN & VRF Isolation | VRFs, Route Distinguishers (RD), Route Targets (RT), MP-iBGP VPNv4 | 🟢 **Validated** |
| **[03](lab-03-l3vpn-option-b.md)** | Inter-AS L3VPN Option B | Inter-AS MP-eBGP VPNv4, ASBR Label Rewriting, Next-Hop Self | 🟢 **Validated** |
| **[04](lab-04-l3vpn-option-c.md)** | Inter-AS L3VPN Option C | BGP Labeled Unicast (BGP-LU RFC 3107/8277), Multi-hop MP-eBGP | 🟢 **Validated** |
| **[05](lab-05-l2vpn-vpws-vpls.md)** | MPLS L2VPN (VPWS & VPLS) | Point-to-Point Pseudowire (EoMPLS RFC 4664), Targeted LDP, VPLS Split-Horizon | 🟢 **Validated** |

---

---

## 🏛️ Phase 3 Architecture & Network Topology Overview

```mermaid
graph LR
    subgraph CustSiteA["Customer Site A (VRF RED)"]
        CE1["ce1 (Customer A)<br/>10.100.1.1/24"]
    end

    subgraph ServiceProviderBackbone["Service Provider MPLS Backbone (AS 65000)"]
        PE1["pe1 (PE Router)<br/>Loopback: 2.2.2.2"] <===>|OSPF + LDP| P1["p1 (P Core Router)<br/>Loopback: 1.1.1.1"]
        P1 <===>|OSPF + LDP| PE2["pe2 (PE Router)<br/>Loopback: 3.3.3.3"]
        PE1 -.-|MP-iBGP VPNv4 Peer Session| PE2
    end

    subgraph CustSiteB["Customer Site B (VRF RED)"]
        CE2["ce2 (Customer A)<br/>10.100.2.2/24"]
    end

    CE1 <===>|eBGP / Static| PE1
    PE2 <===>|eBGP / Static| CE2

    classDef ce fill:#e65100,stroke:#ffb74d,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef p fill:#0d47a1,stroke:#64b5f6,color:#ffffff,stroke-width:2px,font-weight:bold;

    class CE1,CE2 ce;
    class PE1,PE2 pe;
    class P1 p;
```

---

## Google Network Infrastructure Target Competencies

```mermaid
graph TD
    A["MPLS + LDP Underlay<br/>(OSPF, LDP Distribution, LFIB)"] --> B["Single-AS L3VPN & VRFs<br/>(64-bit RD & Extended RTs)"]
    B --> C["Inter-AS L3VPN Option B<br/>(ASBR Label Swapping & MP-eBGP)"]
    C --> D["Hyperscale Inter-AS Option C<br/>(BGP-LU RFC 3107 & Multi-hop MP-eBGP)"]
    
    classDef s fill:#1565c0,stroke:#90caf9,color:#ffffff,stroke-width:2px,font-size:14px,font-weight:bold;
    class A,B,C,D s;
```

---

## Prerequisites

- **[Phase 1 · BGP Fundamentals](../01-bgp/index.md)** — MP-BGP, route reflection, and address family activation.
- **[Foundations · Linux](../linux-foundations/index.md)** — Linux networking and SSH lab environment.

---

## Next Steps & Interview Practice

- **[Self-Test Interview Questions](interview-questions.md)** — Service Provider & WAN Engineering interview question bank covering MPLS, LDP, PHP, RD/RT, and Inter-AS Options A, B, and C.

