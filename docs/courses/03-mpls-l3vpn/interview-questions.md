# Interview Questions — Phase 3 · MPLS & L3VPN

These self-test questions target **Google Network Infrastructure Engineer (NIE)**, **Service Provider Backbone Engineer**, and **WAN Systems Engineer** technical interview scenarios.

---

## MPLS Underlay & LDP Mechanics

??? question "How does MPLS label switching differ from standard IP routing?"
    Standard IP routing performs a **longest-prefix match (LPM)** lookup on the 32-bit destination IPv4 address at every router hop. **MPLS (Multiprotocol Label Switching)** inspects a short, fixed-length 20-bit label in the MPLS shim header and performs an $O(1)$ exact-match hardware table lookup to swap or pop the label, bypassing full routing table lookups at core P routers.

??? question "What is Penultimate Hop Popping (PHP) and why is it used?"
    **Penultimate Hop Popping (PHP)** is an MPLS optimization specified in RFC 3032. The egress PE advertises an **Implicit Null Label (Label 3)** to its upstream P router. The upstream P router pops the transport label before forwarding the packet to the egress PE. This prevents the egress PE from having to perform two hardware label lookups (transport label + service label).

---

## L3VPN & MP-BGP (RFC 4364)

??? question "What is the difference between a Route Distinguisher (RD) and a Route Target (RT)?"
    - **Route Distinguisher (RD — 64 bits)**: Makes overlapping IPv4 customer addresses globally unique by prepending an RD to form a 96-bit VPNv4 prefix (`RD + IPv4 = VPNv4`).
    - **Route Target (RT — Extended Community)**: Defines **VRF routing policy**. Determines which VRFs import and export specific VPNv4 routes across the provider network.

??? question "How does a PE router differentiate between traffic belonging to different customer VRFs upon receiving a packet from the core?"
    The packet carries an **Inner VPN Service Label** in its MPLS label stack. When MP-BGP advertises a VPNv4 route, it allocates a unique service label for that prefix/VRF. The egress PE looks up the inner label in its LFIB (Label Forwarding Information Base) to identify the destination VRF and egress interface.

---

## Inter-AS L3VPN Options A, B, and C

??? question "Compare Inter-AS L3VPN Options A, B, and C in terms of ASBR scalability."
    - **Option A (Back-to-Back VRFs)**: Low scalability. ASBRs must configure sub-interfaces, VRFs, and individual eBGP sessions for every customer. High memory/CPU overhead.
    - **Option B (Inter-AS MP-eBGP VPNv4)**: Medium/High scalability. ASBRs exchange VPNv4 routes directly over MP-eBGP and rewrite Next-Hops/labels. No customer VRFs required on ASBRs.
    - **Option C (BGP-LU RFC 3107 + Multi-hop MP-eBGP)**: **Hyperscale**. ASBRs carry zero customer VPN routes, only exchanging PE loopback reachability via BGP Labeled Unicast (BGP-LU). PEs peer directly via multi-hop MP-eBGP.

??? question "Why do hyperscalers (Google, AWS, Meta) prefer Inter-AS Option C over Option A or B?"
    Option C completely decouples the backbone ASBR core from customer VPN control plane state. ASBRs only store loopback prefixes ($\sim 10,000$ PEs) instead of millions of customer VPN routes. This allows scaling network capacity infinitely without exhausting ASBR router memory or TCAM state.
