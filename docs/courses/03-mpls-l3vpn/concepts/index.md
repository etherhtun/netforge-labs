# Phase 3 Concepts · MPLS & L3VPN Deep Dive

> 📖 **Theory & Architecture Deep Dive.** Understand the protocol mechanics, packet headers, and hardware forwarding tables under the hood before or after building the labs.

---

## Concept Modules

<div class="grid cards" markdown>

-   **[1 · MPLS Architecture & Header Mechanics](01-mpls-architecture.md)**

    ---

    32-bit MPLS Shim Header breakdown (Label, TC/Exp, Bottom-of-Stack S, TTL), Push/Swap/Pop hardware operations, LIB vs LFIB tables.

-   **[2 · LDP & Label Distribution](02-ldp-signaling.md)**

    ---

    LDP UDP 646 hello discovery, TCP 646 session establishment, Downstream Unsolicited (DU) vs Downstream-on-Demand (DoD), Independent vs Ordered control modes.

-   **[3 · L3VPN Control & Data Plane (RFC 4364)](03-l3vpn-architecture.md)**

    ---

    64-bit Route Distinguishers (RD), BGP Extended Community Route Targets (RT), MP-BGP VPNv4 (AFI 1 / SAFI 128), Two-Label Packet Walk, Penultimate Hop Popping (PHP RFC 3032).

-   **[4 · Inter-AS Options A, B, & C](04-inter-as-options.md)**

    ---

    Option A (back-to-back VRFs), Option B (ASBR VPNv4 label swap), Option C (BGP Labeled Unicast RFC 3107/8277 + Multi-hop MP-eBGP).

-   **[5 · L2VPN & Pseudowire Architecture](05-l2vpn-pseudowire.md)**

    ---

    VPWS Point-to-Point Pseudowires (EoMPLS RFC 4664), Control Word (CW), VPLS Split-Horizon loop prevention rules, EVPN-VPWS / EVPN-ELAN.

</div>
