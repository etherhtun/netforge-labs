# 4 · Inter-AS L3VPN Options A, B, & C Architectural Comparison

When connecting customer L3VPNs across multiple autonomous systems or service provider boundaries, RFC 4364 defines three standardized Inter-AS architectural models: **Option A**, **Option B**, and **Option C**.

---

## 1. Inter-AS Option A: Back-to-Back VRF Handoff

In **Option A**, Autonomous System Border Routers (ASBRs) connect via dedicated back-to-back sub-interfaces or VLANs. Each customer VRF requires a separate sub-interface and eBGP session between ASBRs.

```mermaid
graph LR
    subgraph AS65001["AS 65001"]
        PE1["pe1 (PE)"] --- ASBR1["asbr1 (ASBR)<br/>VRF RED & VRF BLUE"]
    end

    subgraph AS65002["AS 65002"]
        ASBR2["asbr2 (ASBR)<br/>VRF RED & VRF BLUE"] --- PE2["pe2 (PE)"]
    end

    ASBR1 <===>|Sub-Intf VRF RED (eBGP)| ASBR2
    ASBR1 <===>|Sub-Intf VRF BLUE (eBGP)| ASBR2

    classDef asbr fill:#4a148c,stroke:#ba68c8,color:#ffffff,stroke-width:2px,font-weight:bold;
    class ASBR1,ASBR2 asbr;
```

- **Pros**: Easy to implement; strict per-VRF QoS and security policy control at boundary.
- **Cons**: Severe scalability limits ($N$ sub-interfaces and $N$ eBGP sessions for $N$ customer VRFs).

---

## 2. Inter-AS Option B: ASBR MP-eBGP VPNv4 Exchange

In **Option B**, ASBRs maintain a single **MP-eBGP VPNv4** session. ASBRs carry zero customer VRFs, but store all VPNv4 routes in their global BGP tables. When re-advertising routes, ASBRs swap the inner VPN label.

```mermaid
graph LR
    subgraph AS65001["AS 65001"]
        PE1["pe1 (PE)"] -.-|MP-iBGP VPNv4| ASBR1["asbr1 (ASBR)"]
    end

    subgraph AS65002["AS 65002"]
        ASBR2["asbr2 (ASBR)"] -.-|MP-iBGP VPNv4| PE2["pe2 (PE)"]
    end

    ASBR1 <===>|Inter-AS MP-eBGP VPNv4<br/>(ASBR Label Swapping)| ASBR2

    classDef asbr fill:#4a148c,stroke:#ba68c8,color:#ffffff,stroke-width:2px,font-weight:bold;
    class ASBR1,ASBR2 asbr;
```

- **Pros**: No customer VRFs required on ASBRs; highly scalable.
- **Cons**: ASBRs must hold all VPNv4 routes in memory ($O(V)$ route table scaling).

---

## 3. Inter-AS Option C: Hyperscale BGP-LU (RFC 3107) + Multi-Hop MP-eBGP

In **Option C**, ASBRs use **BGP Labeled Unicast (BGP-LU RFC 3107 / 8277)** to exchange labels for PE loopback addresses (`/32`) ONLY. PEs form direct **multi-hop MP-eBGP** sessions directly with distant PEs.

```mermaid
graph LR
    subgraph AS65001["AS 65001"]
        PE1["pe1 (PE)<br/>2.2.2.2/32"] --- ASBR1["asbr1 (ASBR)"]
    end

    subgraph AS65002["AS 65002"]
        ASBR2["asbr2 (ASBR)"] --- PE2["pe2 (PE)<br/>3.3.3.3/32"]
    end

    ASBR1 <===>|BGP-LU (RFC 3107)<br/>Exchanges 2.2.2.2 & 3.3.3.3 + Transport Labels| ASBR2
    PE1 -.-|Multi-Hop MP-eBGP VPNv4 (Direct PE-to-PE)| PE2

    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef asbr fill:#4a148c,stroke:#ba68c8,color:#ffffff,stroke-width:2px,font-weight:bold;

    class PE1,PE2 pe; class ASBR1,ASBR2 asbr;
```

- **Pros**: **Hyperscale scaling**. ASBRs carry ZERO customer VRFs and ZERO VPNv4 routes (only PE loopbacks).
- **Cons**: Requires complex BGP-LU routing and end-to-end labeled path coordination.

---

## Summary Comparison Matrix

| Option | Handoff Type | ASBR VRF Requirement | ASBR Route Memory Overhead | Data Plane Label Stack |
|---|---|---|---|---|
| **Option A** | Per-VRF Sub-Interfaces | Yes ($N$ VRFs) | High | 1 Label (Per-VRF Transport) |
| **Option B** | MP-eBGP VPNv4 | No VRFs | Medium (Stores all VPNv4 routes) | 2 Labels (Transport + Swapped VPN Label) |
| **Option C** | BGP-LU + Multi-Hop MP-eBGP | No VRFs | **Ultra-Low** (PE Loopbacks only) | **3 Labels** (Transport + BGP-LU + VPN Label) |
