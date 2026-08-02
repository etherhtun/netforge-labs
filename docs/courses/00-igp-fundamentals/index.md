# Phase 0 — IGP Fundamentals

> 📖 **Reading track — no lab.** OSPF and IS-IS are the best-covered topics in
> networking, and another "configure OSPF on three routers" walkthrough wouldn't
> teach you much. This phase gives you the mental model you need for every later
> phase, and sends you straight on.

Every overlay in this curriculum — VXLAN, MPLS, EVPN, segment routing — assumes one
thing underneath it: **every router already knows how to reach every other router's
loopback.** That job belongs to the IGP.

Get this wrong and nothing above it works. In fact, a broken IGP is the single most
common cause of "MPLS is broken" and "my EVPN peers won't come up" — because both
symptoms look nothing like a routing problem until you check.

---

## What you'll understand

<div class="grid cards" markdown>

-   **[1 · How link-state routing works](01-link-state.md)**

    ---

    Why every router builds an identical map of the network, and what SPF actually
    computes. The shared foundation under both OSPF and IS-IS.

-   **[2 · OSPF](02-ospf.md)**

    ---

    Areas, LSA types, adjacency states, DR/BDR — and how OSPFv3 changes things for
    IPv6. Illustrated with real output from a running fabric.

-   **[3 · IS-IS](03-isis.md)**

    ---

    NET addressing, levels, TLVs, and why service providers keep choosing it —
    especially now that segment routing exists.

-   **[4 · Choosing between them](04-choosing.md)**

    ---

    An honest comparison, dual-stack strategy for IPv4 + IPv6, and the design
    questions that actually come up in interviews.

</div>

---

## What you need first

Comfort with IP addressing, subnetting, and the difference between a routing table
and a forwarding table. If static routes and directly-connected routes make sense,
you're ready.

## Where this leads

| Next | Why it needs this |
|---|---|
| **Phase 1 · BGP** | iBGP peers over loopbacks the IGP must already reach |
| **Phase 3 · MPLS** | LDP binds labels to prefixes *the IGP put in the table* — no route, no label |
| **Phase 4 · EVPN** | VTEPs source tunnels from loopbacks the IGP advertises |

!!! tip "The one rule worth carrying forward"
    **Never debug an overlay before proving the underlay.** If two devices can't
    ping each other's loopbacks over plain IP, nothing you do at the overlay layer
    will help. It costs thirty seconds to check and it will save you hours — this is
    not hypothetical advice; it's the exact mistake that cost an evening while
    building [Phase 3's lab](../03-mpls-l3vpn/lab-01-mpls-ldp.md).
