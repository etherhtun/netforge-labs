# Interview Questions — Phase 3.5 · Segment Routing (SR-MPLS & SRv6)

These self-test questions target **Google Network Infrastructure Engineer (NIE)**, **FAANG WAN Systems Engineer**, and **Segment Routing Specialist** technical interview scenarios.

---

## SR-MPLS & SID Mechanics

??? question "What is the primary architectural advantage of Segment Routing over RSVP-TE and LDP?"
    Segment Routing shifts state from the network core (P routers) to the packet header at the headend ingress router (PE). Core routers carry **zero soft state** (no RSVP Refresh messages or signaling timers), eliminating signaling overhead and allowing networks to scale infinitely.

??? question "What is the difference between a Prefix SID, a Node SID, and an Adjacency SID?"
    - **Prefix SID**: Global segment representing an IP prefix.
    - **Node SID**: Special Prefix SID allocated out of the SRGB (`16000–23999`) representing a specific router's loopback IP. Globally unique domain-wide.
    - **Adjacency SID**: Local segment representing a specific physical link. Allocated dynamically (`24000+`) and only locally significant to the originating router.

---

## Ti-LFA & Sub-50ms Fast Reroute

??? question "Why does Ti-LFA guarantee 100% protection against link/node failure while classic LFA fails on ring topologies?"
    Classic LFA (RFC 5286) only evaluates basic neighbor inequalities. On ring topologies, neighbor routers would re-route traffic back across the failed link, creating micro-loops. **Ti-LFA (Topology-Independent LFA)** calculates exact P-Space and Q-Space node intersections and pushes explicit segment label stacks to force traffic along the pre-computed post-convergence path.

??? question "Explain P-Space, Q-Space, and PQ Node in Ti-LFA calculations."
    - **P-Space**: Set of routers reachable from the source router without traversing the failed link.
    - **Q-Space**: Set of routers from which the target destination can be reached without traversing the failed link.
    - **PQ Node**: The intersection node ($\text{P} \cap \text{Q}$) where traffic can be safely delivered without looping.

---

## SR-PCE & BGP Color Steering

??? question "How does BGP Color Extended Community steering work in SR-TE?"
    The headend router evaluates inbound BGP routes carrying a **Color Extended Community** (e.g. `color:100`). If a matching Segment Routing TE policy exists for `Color 100 + Endpoint IP`, the router automatically installs the BGP route into the SR-TE tunnel forwarding entry, steering traffic into the explicit low-latency or high-bandwidth label stack.
