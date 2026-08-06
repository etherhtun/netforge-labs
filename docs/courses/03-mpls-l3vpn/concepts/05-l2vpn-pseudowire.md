# 5 · L2VPN & Pseudowire Architecture (VPWS & VPLS)

Layer 2 Virtual Private Networks (L2VPN) transport customer Layer 2 Ethernet frames intact across an IP/MPLS core provider network.

---

## 1. Virtual Private Wire Service (VPWS / Pseudowire RFC 4664)

**VPWS (Ethernet over MPLS — EoMPLS)** creates a point-to-point emulated wire (Pseudowire) connecting two customer sites.

```mermaid
graph LR
    CE1["ce1 (Customer L2 Switch)<br/>Port Et1"] ===>|Untagged / 802.1Q Frame| PE1["pe1 (PE Router)"]
    PE1 -.-|Targeted LDP (tLDP) Pseudowire VC ID 100|-.- PE2["pe2 (PE Router)"]
    PE2 ===>|Untagged / 802.1Q Frame| CE2["ce2 (Customer L2 Switch)<br/>Port Et1"]

    classDef ce fill:#e65100,stroke:#ffb74d,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    class CE1,CE2 ce; class PE1,PE2 pe;
```

### The 4-Byte Pseudowire Control Word (CW)

To preserve packet ordering across ECMP paths in an IP/MPLS underlay network, a 4-byte **Control Word (CW)** is inserted between the inner PW label and the customer Layer 2 Ethernet frame:

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
| Reserved (0000) | Flags | Length (6b) | Sequence Number (16b) |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

---

## 2. Virtual Private LAN Service (VPLS RFC 4762)

**VPLS** extends L2VPN to point-to-multipoint, operating as a virtual distributed Ethernet switch across the MPLS core.

```mermaid
graph TD
    PE1["pe1 (PE)"] -.-|Targeted LDP Pseudowire Mesh|-.- PE2["pe2 (PE)"]
    PE2 -.-|Targeted LDP Pseudowire Mesh|-.- PE3["pe3 (PE)"]
    PE3 -.-|Targeted LDP Pseudowire Mesh|-.- PE1

    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    class PE1,PE2,PE3 pe;
```

### VPLS Split-Horizon Loop Prevention Rule

Because VPLS builds a full mesh of pseudowires between all participating PE routers without running Spanning Tree Protocol (STP) across the provider core:

> 🛑 **VPLS Split Horizon Rule**: A frame received over an ingress Pseudowire from another PE router must **NEVER** be re-forwarded out over any other Pseudowire to a third PE router! It can only be forwarded out to local customer-facing access interfaces.

---

## 3. Transition to BGP EVPN (Phase 4)

While traditional L2VPNs rely on Targeted LDP and data-plane flood-and-learn MAC discovery, **BGP EVPN (RFC 7432 / RFC 8214)** replaces tLDP with BGP control-plane MAC learning (AFI 25 / SAFI 70), supporting active-active multihoming and optimal routing.
