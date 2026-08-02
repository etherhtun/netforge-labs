# 4 · Choosing between them

Both protocols are link-state, both run Dijkstra, both scale to very large networks
in competent hands. Anyone claiming one is simply better is selling something.

What follows is the honest version: where they genuinely differ, and which
differences actually change a design decision.

---

## Side by side

| | **OSPF** | **IS-IS** |
|---|---|---|
| Runs on | IP (protocol 89) | layer 2 directly |
| Hierarchy | areas, all touching area 0 | levels L1 / L2 |
| Area membership | per **interface** | per **router** |
| Backbone | area 0, a numbered area | contiguous chain of L2 routers |
| Advertisement | several LSA types | one LSP per router, built of TLVs |
| Extensibility | often needs protocol changes | new TLV |
| IPv6 | OSPFv3 — a separate protocol | a TLV in the same instance |
| Dual-stack | two instances, two databases | one instance, single or multi-topology |
| LAN election | DR + BDR, no pre-emption | DIS, no backup, pre-emptable |
| Segment routing | supported, arrived later | first-class, arrived naturally |
| Common in | enterprise, data centre | service provider backbone |

---

## The differences that actually matter

**Extensibility.** This is the big one. TLV encoding means IS-IS absorbs new
capabilities without a version bump. IPv6 and segment routing both landed on IS-IS
as extensions while OSPF needed a whole new protocol for the former.

If your roadmap includes **segment routing**, that alone is a real argument for
IS-IS.

**Backbone flexibility.** Growing an OSPF network means extending area 0, sometimes
with virtual links when geography doesn't cooperate. Growing an IS-IS backbone
means enabling L2 on more routers. Organisations that grow by acquisition feel this
difference sharply.

**Attack surface.** IS-IS can't be reached from off-link because there's no IP
header to route toward it. For an internet-facing backbone that's a meaningful
property, not a technicality.

**Operational familiarity.** Working against all of the above: **far more engineers
know OSPF.** A protocol your team can troubleshoot at 3am beats a technically
superior one they can't. This is a legitimate engineering argument and it wins more
often than protocol purists like to admit.

---

## Choosing, in practice

**Choose OSPF when** you're running an enterprise or data-centre network, your team
already knows it, and segment routing isn't on the roadmap. It's well understood,
well tooled, and its area model maps cleanly onto how most enterprises are already
organised.

**Choose IS-IS when** you're building a service-provider backbone, you expect to
deploy segment routing or traffic engineering, you need to grow or merge networks
without redesigning the backbone, or you want the protocol off the IP attack
surface.

**Don't switch a working network without a reason.** Migrating IGP is disruptive
and rarely pays for itself on elegance alone. "We might want SR one day" is not
sufficient; "we are deploying SR next quarter" is.

!!! note "In a VXLAN-EVPN fabric, this barely matters"
    A spine-leaf underlay has one job: make every loopback reachable. It's usually
    a single area with point-to-point links and no hierarchy at all.

    Both protocols do that perfectly. Pick whichever your team knows —
    [Phase 4](../04-evpn/lab-01-vxlan-evpn.md) uses OSPF for exactly this reason. Some
    fabrics use eBGP instead, which [Phase 1](../../roadmap.md) covers.

---

## Dual-stack strategy

Adding IPv6 is where the two protocols diverge most operationally.

**With OSPF** you run two protocols. OSPFv2 for IPv4, OSPFv3 for IPv6 — separate
adjacencies, separate databases, separate SPF. They can legitimately disagree, and
IPv4 taking one path while IPv6 takes another across the same links is normal
rather than a fault. Every troubleshooting session becomes two.

**With IS-IS** you run one. Then choose:

- **Single topology** — one SPF for both families. Simpler, but it assumes every
  link carries both. An IPv4-only link will still attract IPv6 traffic, which then
  black-holes.
- **Multi-topology** — separate SPF per family, so partial deployment is safe.

**The practical advice:** during any incremental IPv6 rollout, use multi-topology.
Single topology is only safe once dual-stack is genuinely universal and you intend
to keep it that way — and networks rarely stay that tidy.

---

## Interview questions

??? question "You're designing a new provider backbone and expect to deploy segment routing. Which IGP, and why?"
    IS-IS. Segment routing extensions are carried as TLVs, which IS-IS was built to
    absorb without protocol changes — SR landed there first and most naturally. The
    L2 backbone is also easier to extend as the network grows, and running off IP
    reduces exposure. OSPF supports SR too, so this is a preference rather than a
    hard requirement, but it's the direction the ecosystem moved.

??? question "Your enterprise runs OSPF and someone proposes migrating to IS-IS for elegance. What's your response?"
    Ask what problem it solves. If there's no concrete driver — segment routing,
    backbone growth pain, a security requirement — the migration cost and the risk
    of operating a protocol the team knows less well outweigh the design benefits.
    A protocol your engineers can debug under pressure is worth more than a
    marginally better one they can't.

??? question "Why is dual-stack simpler on IS-IS than on OSPF?"
    IS-IS carries IPv6 as a TLV inside the same instance, so it's one protocol, one
    adjacency, one database. OSPF needs OSPFv3 alongside OSPFv2 — two independent
    protocols that can disagree about paths and must both be troubleshot.

??? question "What breaks with single-topology IS-IS dual-stack?"
    It computes one shortest-path tree for both families, assuming every link
    carries both. If some links are IPv4-only, IPv6 traffic is still routed onto
    them and black-holes. Multi-topology computes a separate tree per family and
    avoids this.

??? question "Does the IGP choice matter for a VXLAN-EVPN fabric?"
    Very little. The underlay just needs every loopback reachable, typically in a
    single flat area over point-to-point links. Both protocols do that equally
    well, so the decision comes down to operational familiarity — or you skip the
    IGP entirely and use eBGP as the underlay.

---

## Where to go next

You now have what every later phase assumes.

| Next | What it builds on this |
|---|---|
| **[Phase 1 · BGP](../../roadmap.md)** | iBGP peers over loopbacks the IGP makes reachable |
| **[Phase 3 · MPLS](../03-mpls-l3vpn/index.md)** | LDP binds labels to IGP-learned prefixes — no route, no label |
| **[Phase 4 · EVPN](../04-evpn/lab-01-vxlan-evpn.md)** | VTEPs source tunnels from IGP-advertised loopbacks |

And the rule worth carrying into all of them: **prove the underlay before debugging
the overlay.** Almost every "the overlay is broken" report turns out to be a
missing route wearing a costume.
