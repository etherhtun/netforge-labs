# Interview questions — IGP

Self-test bank for the whole phase. Each page also ends with questions on its own
material; this collects them and adds the **factual-recall** questions that
screening rounds lean on.

Try to answer before expanding. If an answer surprises you, go back to the page —
the reasoning matters more than the fact.

---

## Link-state fundamentals

??? question "Why is link-state better than distance-vector for large networks?"
    Distance-vector routers exchange *conclusions* ("X costs 5") and relay them
    onward, so bad news propagates hop by hop and a router can believe a path that
    no longer exists. Link-state routers flood the *facts* they know — their own
    links and costs — so every router builds an identical map and computes paths
    independently. That gives fast convergence and structural loop-freedom instead
    of loop-prevention hacks.

??? question "What does SPF actually compute, and how often does it run?"
    Dijkstra's algorithm over the LSDB with the local router as root, producing a
    shortest-path tree to every destination. It re-runs on any topology change.
    Because a full SPF is expensive, implementations throttle it — an initial short
    delay, then increasing back-off if changes keep arriving — so a flapping link
    can't consume the CPU.

??? question "What happens if two routers in an area disagree about the topology?"
    They compute different trees and can forward inconsistently — which is how a
    link-state protocol produces a loop. Identical LSDBs within an area are a
    correctness requirement, not an optimisation. Compare database checksums; a
    mismatch is a genuine alarm.

??? question "Why do areas exist if link-state already scales?"
    Because it doesn't scale for free. Bigger LSDB means more memory and heavier
    SPF, and every change anywhere forces recomputation everywhere. Areas contain
    topology detail and exchange summaries at borders. You trade visibility for
    stability — a flap in one area no longer disturbs the whole network.

??? question "What is BFD and why use it instead of aggressive IGP timers?"
    Bidirectional Forwarding Detection is a lightweight protocol that exchanges
    very fast hellos and signals its client protocols when a path fails. It detects
    failures in milliseconds where OSPF's default dead interval takes 40 seconds.
    You *could* lower OSPF timers instead, but that burdens the routing process
    itself and risks false positives under load; BFD is purpose-built, cheaper, and
    can serve OSPF, IS-IS and BGP simultaneously.

---

## OSPF — structure

??? question "Why must every OSPF area connect to area 0?"
    OSPF has no loop-prevention *between* areas — inter-area routes are summaries a
    router can't see behind, effectively distance-vector. Forcing all inter-area
    traffic through one backbone makes loops structurally impossible rather than
    algorithmically prevented.

??? question "Name the OSPF area types and what each blocks."
    **Standard** blocks nothing. **Stub** blocks type 5 externals, substituting a
    default. **Totally stubby** blocks types 3, 4 and 5, leaving only intra-area
    plus a default. **NSSA** blocks type 5 but permits type 7 so the area can have
    its own external source. **Totally NSSA** blocks 3, 4 and 5 while still allowing
    type 7.

??? question "Why does NSSA exist when stub areas already work?"
    A stub area by definition cannot carry external routes — but an area may be
    stub-like in every other respect while still having its own redistributing
    router. NSSA resolves the contradiction with type 7: functionally external, but
    permitted inside an NSSA, and translated to type 5 by the ABR on the way out.

??? question "Can area 0 be a stub area?"
    No. The backbone carries transit for every other area, so blocking LSA types
    there would break inter-area routing by definition.

??? question "List the OSPF LSA types you'd expect in a multi-area network."
    Type 1 router LSAs and type 2 network LSAs within each area; type 3 summaries
    from ABRs describing other areas; type 4 telling you how to reach an ASBR; type
    5 externals from an ASBR; type 7 in place of type 5 inside an NSSA.

??? question "How does OSPF area membership differ from IS-IS?"
    OSPF assigns each **interface** to an area, so one router can hold interfaces in
    several areas — that's what an ABR is. IS-IS assigns the **whole router** to an
    area; the equivalent of an ABR is a router running both L1 and L2.

---

## OSPF — path selection

??? question "OSPF learns the same prefix as intra-area cost 500 and inter-area cost 10. Which wins?"
    The **intra-area** route, despite costing fifty times more. OSPF compares route
    *type* before cost: intra-area, then inter-area, then E1, then E2. Cost only
    breaks ties within a class.

??? question "What is the difference between E1 and E2 external routes?"
    **E2** carries a fixed metric — whatever the ASBR set — regardless of how far
    the receiving router is from it, and is the default. **E1** adds the internal
    cost of reaching the ASBR to the external metric, so it grows with distance.

??? question "You have two exits to the same external destination and traffic is taking the far one. Why?"
    Almost certainly E2. With a fixed metric every router sees both exits as equal
    cost and picks by tiebreaker rather than proximity. Redistribute as **E1** so
    each router adds its own distance to the ASBR and naturally prefers the nearer
    exit.

??? question "How does a router choose its OSPF router ID?"
    Manually configured `router-id` first; otherwise the highest IP on an up
    loopback; otherwise the highest IP on any up physical interface. Always set it
    explicitly — an automatic ID can change when interfaces change, and since it's
    embedded in every LSA that router originated, a change forces area-wide
    re-flooding and SPF. Note it doesn't take effect until the process restarts.

---

## OSPF — operations

??? question "Two routers are stuck in ExStart/Exchange. What do you check?"
    **MTU.** During database exchange each side sends packets sized to its own MTU;
    if the peer can't receive them the exchange never completes. Hellos are small
    and pass fine, which is what makes it confusing — small packets work, large ones
    don't.

??? question "A router on a LAN sits at 2-Way and never reaches Full. Broken?"
    Usually not. On a multi-access segment only DR and BDR go to Full; everyone else
    deliberately stays at 2-Way with each other. It's a problem only if that router
    should have become DR or BDR.

??? question "What are the default hello and dead intervals?"
    10 and 40 seconds on broadcast and point-to-point links; 30 and 120 on NBMA and
    point-to-multipoint. Dead is conventionally 4× hello, and both must match
    between neighbours or no adjacency forms.

??? question "Why change the reference bandwidth, and what's the catch?"
    Cost is reference ÷ interface bandwidth with a 100 Mbps default, so every link
    at 100 Mbps or faster lands on cost 1 — a 1G and a 100G link are
    indistinguishable. Raising the reference restores differentiation. The catch is
    it must be **identical on every router**, since a mismatch means routers
    disagree about cost and compute inconsistent trees.

??? question "Where can OSPF summarise, and with which command?"
    Only at borders. `area <id> range` on an **ABR** summarises inter-area type 3
    routes; `summary-address` on an **ASBR** summarises externals. They aren't
    interchangeable. Summarisation can't happen mid-area because routers inside an
    area must hold identical databases.

??? question "What is a virtual link and when is it appropriate?"
    A tunnel through a non-backbone transit area connecting a detached area to area
    0, usually after a merger or a split backbone. It's a legitimate repair but a
    poor design: it's fragile, depends on the transit area staying healthy, and
    conceals a structural problem. If one is load-bearing, re-home the area instead.

??? question "What does passive-interface do and where should it go?"
    Advertises the interface's network into OSPF while suppressing hellos on it. Use
    it on any interface with no OSPF neighbour — user subnets, loopbacks. It removes
    pointless adjacency attempts and a small attack surface.

??? question "Why prefer point-to-point over broadcast on a routed link?"
    With only two routers there's nothing to elect, so DR election adds startup
    delay for no benefit. Point-to-point forms adjacency faster and keeps the
    database simpler by omitting the type-2 network LSA.

---

## OSPFv3

??? question "What are the main differences between OSPFv2 and OSPFv3?"
    v3 operates **per link** rather than per subnet, so addressing doesn't gate
    adjacency; neighbours peer over **link-local** `fe80::` addresses; addressing is
    separated out of the router and network LSAs so topology and prefixes travel
    independently; and built-in authentication is dropped in favour of IPsec. The
    area model and algorithm are unchanged.

??? question "Router IDs in an IPv6-only OSPFv3 network — what's the gotcha?"
    They're still **32-bit**, written dotted-quad. With no IPv4 addresses anywhere
    there's nothing to derive one from, so it **must** be configured manually. A
    missing router ID is a common reason OSPFv3 silently refuses to start.

??? question "What does dual-stack cost you on OSPF?"
    Two independent protocols — v2 and v3 — with separate adjacencies, databases and
    SPF computations. They can legitimately disagree, so IPv4 and IPv6 may take
    different paths over the same links, and every troubleshooting session is two.

---

## IS-IS

??? question "Why do service providers favour IS-IS?"
    It runs directly on layer 2, so it can't be reached — or attacked — from off
    link. TLV encoding lets new capabilities (IPv6, segment routing, TE) arrive as
    extensions rather than protocol rewrites. And the L2 backbone is a contiguous
    set of routers rather than a numbered area, making growth and mergers far less
    disruptive.

??? question "Break down the NET 49.0001.0000.0000.0001.00."
    `49` is the private AFI, the OSI equivalent of RFC 1918. `0001` is the area,
    which belongs to the **whole router**. `0000.0000.0001` is the system ID —
    exactly six bytes, unique domain-wide, and the part that actually identifies the
    router. Trailing `00` is the NSEL, always `00` on a router.

??? question "What is the ATT bit and what problem does it create?"
    An L1/L2 router sets the attached bit in its L1 LSP to advertise itself as an
    exit from the area. L1 routers then default toward the **nearest** such router.
    The problem is nearest isn't always best — if the destination sits behind a
    different L1/L2 router, traffic reaches the closest exit and then crosses the
    backbone anyway.

??? question "How does route leaking fix that, and why not leak everything?"
    An L1/L2 router leaks specific L2 prefixes down into L1 so L1 routers see real
    destinations instead of only a default, and can pick the right exit directly.
    Leaking everything recreates the full-table problem levels existed to solve —
    leak only where exit choice genuinely matters.

??? question "What is the overload bit used for?"
    It advertises "reachable, but don't route transit through me." Directly attached
    destinations still work; the router stops being used as a path to anywhere else.
    Set automatically at boot so a router whose BGP table is still loading doesn't
    black-hole transit, and manually to drain traffic before maintenance — cleaner
    than shutting interfaces.

??? question "Why does metric-style wide matter beyond larger numbers?"
    Narrow metrics cap at 63 per link, which can't express modern bandwidth
    differences. Wide metrics are carried in TLVs with room for extra information,
    making them a **prerequisite for segment routing and traffic engineering**.
    Mixing styles in one domain also causes cost disagreements between routers.

??? question "How does the DIS differ from OSPF's DR?"
    There's **no backup** — a new election simply happens, which IS-IS treats as
    fast enough — and the DIS **can be pre-empted** by a higher-priority router
    arriving later, where OSPF's DR deliberately holds its position to avoid churn.

---

## Design and comparison

??? question "New provider backbone, segment routing planned. Which IGP?"
    IS-IS. SR extensions are TLVs, which IS-IS absorbs without protocol change — SR
    landed there first and most naturally. The L2 backbone is easier to grow, and
    running off IP reduces exposure. OSPF supports SR too, so this is a strong
    preference rather than a hard requirement.

??? question "Someone proposes migrating a working OSPF network to IS-IS for elegance."
    Ask what problem it solves. Absent a concrete driver — segment routing,
    backbone growth pain, a security requirement — migration cost and the risk of
    running a protocol the team knows less well outweigh the design benefits. A
    protocol your engineers can debug under pressure is worth more than a marginally
    better one they can't.

??? question "Why is dual-stack simpler on IS-IS?"
    IPv6 is a TLV inside the same instance — one protocol, one adjacency, one
    database. OSPF needs v3 alongside v2: two protocols that can disagree and must
    both be troubleshot.

??? question "When is single-topology IS-IS dual-stack wrong?"
    Whenever IPv4 and IPv6 aren't on every link. Single topology computes one tree
    for both families, so IPv6 can be routed down an IPv4-only link and black-hole.
    Multi-topology computes a tree per family and is the safe choice during any
    incremental rollout.

??? question "Does IGP choice matter for a VXLAN-EVPN fabric?"
    Barely. The underlay only needs every loopback reachable, typically one flat
    area over point-to-point links. Both do that equally well, so it comes down to
    operational familiarity — or you skip the IGP and use eBGP as the underlay.

---

## The one that isn't really about IGP

??? question "MPLS shows no labels, BGP won't peer, and VXLAN tunnels don't form. Where do you look?"
    **The IGP.** All three symptoms are the same underlying fault wearing different
    costumes: the loopbacks aren't reachable. LDP binds labels to IGP-learned
    prefixes, iBGP peers over loopbacks, VTEPs source tunnels from them.

    The usual cause is an interface with an IP address that was never put **into**
    the IGP — most often a loopback missing its `ip ospf area` statement. Addressing
    an interface and advertising it are different things.

    Prove loopback-to-loopback reachability before touching any overlay. It costs
    thirty seconds and it is, empirically, where the fault usually is.
