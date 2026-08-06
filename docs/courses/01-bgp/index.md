# Phase 1 — BGP Fundamentals & Policies

> ✅ **Labs 01–04 validated** on Arista cEOS 4.32.0F.

Every other protocol in this curriculum decides *what the shortest path is*. BGP
decides *what you're willing to accept and advertise* — a policy protocol wearing a
routing protocol's clothes.

That difference explains almost everything about it. BGP is slower to converge and
harder to reason about than OSPF, and in exchange it scales to the whole internet
and lets you express business relationships in configuration.

---

## Labs

| Lab | You build | Status |
|---|---|---|
| **[01](lab-01-ebgp-ibgp.md)** | Two ASes, eBGP + iBGP, and the next-hop trap | ✅ Validated |
| **[02](lab-02-isis-underlay.md)** | Swap the IGP to IS-IS under a live BGP deployment | ✅ Validated |
| **[03](lab-03-route-reflectors.md)** | Route reflectors — breaking the iBGP full mesh | ✅ Validated |
| **[04](lab-04-dual-homed-edge.md)** | Multihomed edge — two upstreams, hosts, switch, VRRP, policy | ✅ Validated |
| 05 | Path selection and policy — local-pref, MED, communities | 📋 Planned |

---

## The concepts

Short primers on what labs alone don't teach — the state machine, attributes, the
best-path algorithm, policy tooling, and route reflection.

[Start with the concepts →](concepts/index.md) ·
[Interview questions →](concepts/interview-questions.md)

---

## Prerequisites

- **[Phase 0 · IGP Fundamentals](../00-igp-fundamentals/index.md)** — iBGP peers
  over loopbacks the IGP has to make reachable. Lab 01 demonstrates exactly what
  breaks when it doesn't.
- **[Foundations · Linux](../linux-foundations/index.md)** — helpful, not required.
- A working lab host — see
  **[lab setup](../../getting-started/lab-setup-macos.md)**.

---

## Why BGP is different

| | IGP (OSPF, IS-IS) | BGP |
|---|---|---|
| Optimises for | shortest path | **policy**, then path |
| Scope | one organisation | between organisations |
| Metric | cost, from bandwidth | a stack of attributes you control |
| Convergence | seconds | slower, deliberately |
| Scale | thousands of routes | ~1,000,000 internet routes |
| Trust | all routers cooperate | **peers may be adversarial** |

That last row drives the rest. An IGP assumes every participant is honest and
correct. BGP assumes the peer is a different company with different interests —
so nothing is accepted implicitly, and everything is filterable.

---

## The one idea to carry in

**eBGP and iBGP are the same protocol with different rules**, and the differences
follow from one fact: eBGP crosses a trust boundary, iBGP doesn't.

| | eBGP | iBGP |
|---|---|---|
| Between | different ASes | same AS |
| Peers on | interface addresses | **loopbacks** |
| Default TTL | 1 (assumes directly connected) | normal |
| AS path | **prepends** on advertise | unchanged |
| Re-advertises to | anyone | **never to another iBGP peer** |
| Next hop | set to self | **unchanged** ← Lab 01's trap |

The last row causes more first-deployment failures than everything else combined,
which is why Lab 01 walks into it deliberately rather than warning you around it.

---

## Where this leads

| Next | How it uses BGP |
|---|---|
| **[Phase 3 · MPLS & L3VPN](../03-mpls-l3vpn/index.md)** | L3VPN is MP-BGP with VPNv4 routes and extra headers |
| **[Phase 4 · EVPN](../04-evpn/index.md)** | EVPN is a BGP address family; the fabric is iBGP with route reflectors |
| **Phase 2 · Internet Edge** | multi-homing, RPKI and peering are all BGP policy |
