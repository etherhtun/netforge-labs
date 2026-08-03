# Interview questions — BGP

BGP is usually the largest single topic in a routing interview. This bank covers the
whole phase.

---

## Sessions and state

??? question "What transport does BGP use, and what follows from that?"
    TCP port 179. Because TCP is reliable and connection-oriented, BGP doesn't
    implement retransmission or ordering itself, sessions must be explicitly
    configured rather than discovered, and a session dies when the TCP connection
    does.

??? question "Name the BGP states in order."
    Idle → Connect → Active → OpenSent → OpenConfirm → Established. Only
    **Established** exchanges routes.

??? question "A session is flapping between Idle and Active. What's wrong?"
    TCP can't be established. `Active` sounds healthy but means "TCP failed,
    retrying." Check reachability to the peer address, that TCP/179 isn't filtered,
    and the peer address itself. For iBGP it's usually the peer's loopback missing
    from the IGP.

??? question "Stuck in OpenSent — what does that point to?"
    The Open message was sent but the reply didn't validate. Usually a **remote-AS
    mismatch**, or duplicate router IDs on the two peers.

??? question "What are the four BGP message types?"
    **Open** (negotiate AS, router ID, hold time, capabilities), **Update**
    (advertise/withdraw prefixes), **Keepalive** (liveness), and **Notification**
    (error — and it always closes the session).

??? question "Default keepalive and hold timers?"
    Keepalive **60s**, hold **180s** — hold is conventionally 3× keepalive. The
    lower of the two peers' hold times is negotiated in the Open message.

??? question "Would you lower BGP timers for faster convergence?"
    Rarely. Aggressive timers risk tearing down sessions under CPU load or transient
    congestion, and a bouncing session is worse than slow detection. Use **BFD** —
    sub-second detection in a lightweight protocol that signals BGP — instead of
    making BGP itself fragile.

---

## eBGP vs iBGP

??? question "How do eBGP and iBGP differ?"
    Same protocol, different rules because eBGP crosses a trust boundary. eBGP peers
    on interface addresses with TTL 1, prepends the AS path, and sets next-hop to
    self. iBGP peers on loopbacks, leaves AS path and next-hop unchanged, carries
    local-pref, and never re-advertises iBGP-learned routes to other iBGP peers.

??? question "Why do iBGP peers use loopbacks?"
    iBGP peers are typically multiple hops apart with redundant paths. A loopback
    session survives any single link failure because the IGP reroutes around it —
    provided the IGP advertises the loopbacks, which is the dependency people miss.

??? question "What is next-hop-self and when do you need it?"
    When a router advertises an eBGP-learned prefix to iBGP peers, it leaves the next
    hop pointing into the neighbouring AS — an address internal routers can't reach.
    `next-hop-self` rewrites it to the advertising router's own address, which the
    IGP advertises.

??? question "BGP shows a route as valid and best but traffic doesn't reach it."
    Check whether the next hop is reachable by a **data-plane** route. BGP marks a
    route valid if the next hop resolves at all — including via a default route. In
    labs that default is often the management interface, so the route installs and
    silently sends traffic out-of-band. Verify with `show ip route <next-hop>` and
    look at what the FIB entry actually points to.

??? question "Why can't iBGP re-advertise routes to other iBGP peers?"
    Loop prevention. iBGP doesn't prepend the AS path, so it can't detect loops that
    way. The rule forces every speaker to hear routes directly — hence the full mesh
    — and route reflectors relax it using ORIGINATOR_ID and CLUSTER_LIST instead.

---

## Attributes

??? question "What are the attribute categories and why do they matter?"
    Well-known mandatory (ORIGIN, AS_PATH, NEXT_HOP), well-known discretionary
    (LOCAL_PREF), optional transitive (COMMUNITY), optional non-transitive (MED,
    ORIGINATOR_ID, CLUSTER_LIST). They define what a router does with an attribute
    it doesn't understand — transitive ones are passed on, which is how communities
    survive crossing networks that ignore them.

??? question "Local preference vs MED — which controls what?"
    **Local-pref** is your AS's decision about which exit to use — it controls
    **outbound** traffic and is authoritative within your AS. **MED** is a hint to a
    neighbouring AS about which entrance to use, so it influences **inbound** traffic
    — but only as a request, since their local-pref is compared first.

??? question "Why is MED only compared between paths from the same AS?"
    Because MED values aren't a common scale — one provider's 50 means nothing
    relative to another's 500. Comparing across ASes is meaningless by default,
    though `always-compare-med` will do it.

??? question "What is weight and how does it differ from local-pref?"
    Weight is **local to one router** and never advertised; local-pref propagates
    through the AS via iBGP. Weight is step 1 and local-pref step 2. Prefer
    local-pref for anything AS-wide — weight silently affects one box, which makes
    for confusing troubleshooting.

??? question "What do the origin codes mean?"
    `i` (IGP) from a `network` statement, `e` (EGP) historical, `?` (incomplete)
    from redistribution. Preference order is IGP > EGP > incomplete, compared at
    step 5. A redistributed route loses to an otherwise-equal one from a `network`
    statement.

??? question "What does NO_EXPORT do?"
    A well-known community meaning "don't advertise this outside the AS." Useful for
    more-specific prefixes you want used internally, or by a directly-connected peer,
    without announcing them to the wider internet.

---

## Best-path selection

??? question "Walk through the best-path algorithm."
    Weight (highest) → local-pref (highest) → locally originated → AS path length
    (shortest) → origin (IGP < EGP < incomplete) → MED (lowest) → eBGP over iBGP →
    IGP metric to next hop (lowest) → oldest path → lowest router ID → lowest
    neighbour IP. **The first step that differs decides it**; nothing below is
    evaluated.

??? question "Path A: local-pref 200, AS path of 3. Path B: local-pref 100, AS path of 1. Which wins?"
    **A**, at step 2. Local preference is compared before AS path, so B's shorter
    path is never considered. This is the most common real-world surprise — "the
    shorter path isn't being used" is nearly always local-pref doing its job.

??? question "What is hot-potato routing?"
    Step 8 — when everything else ties, prefer the path with the lowest IGP metric to
    the next hop, i.e. the nearest exit. You hand traffic off as soon as possible and
    let the other AS carry it, which is cheapest for you.

??? question "Why is 'oldest path' a tiebreak, and what's the downside?"
    Stability — don't churn the best path just because a new equal one appeared. The
    downside is that the outcome depends on **arrival order**, so two routers with
    identical tables can choose differently, which is unpleasant to debug.

??? question "Two equal-cost paths to a provider. Why is only one used?"
    BGP installs one best path by default. `maximum-paths N` enables multipath;
    candidates must tie down to the IGP metric and have the same AS path length. Only
    the best path is still advertised onward.

---

## Policy

??? question "Difference between a prefix list and a route map?"
    A prefix list matches prefixes and lengths — it only selects. A route map is the
    policy engine: ordered clauses that match on prefix lists, AS paths or
    communities, and then permit, deny, or **set attributes**. Route maps are what
    actually change local-pref, MED or communities.

??? question "What happens if a route map has no matching clause?"
    Implicit deny — everything is dropped. Applying an unfinished route map to a
    production peer takes that session's routes to zero instantly. Verify with
    `show ip bgp neighbors <ip> received-routes` against what's in the table.

??? question "What does the AS-path regex `^$` match, and why does it matter?"
    An empty AS path — locally originated routes. Applied outbound to your providers
    it means "advertise only my own prefixes," which prevents you becoming
    accidental transit. That mistake is behind a fair number of large internet
    incidents.

??? question "How would you use communities to keep policy manageable?"
    Tag on ingress by route source — customer, peer, transit — then have every other
    policy match the community rather than re-derive origin. Adding a customer
    becomes one tag instead of edits across every route-map.

??? question "Why set maximum-prefix on eBGP peers?"
    A peer leaking a full table can exhaust memory and take down **every** session.
    Max-prefix tears down just that one instead. Set it near expected volume — a
    customer sending 10 prefixes shouldn't be capped at a million.

??? question "What is GTSM and why is it better than ebgp-multihop?"
    eBGP defaults to TTL 1, assuming direct connection. `ebgp-multihop` weakens that
    for multihop peering. GTSM inverts the test — it requires arriving packets to
    have a *high* TTL, which only a nearby sender achieves — so off-path spoofed
    packets are dropped in hardware before BGP sees them.

??? question "You need to change an inbound policy. How, without dropping the session?"
    `clear ip bgp <peer> soft in`, which uses the negotiated **route refresh**
    capability to ask the peer to resend. Non-disruptive. Never `clear ip bgp *` on
    production — that resets every session and re-converges the whole table.

??? question "Why is dampening used cautiously now?"
    Aggressive dampening suppressed legitimate prefixes for hours after brief
    instability, making outages longer than the flapping itself. It was widely
    deployed, then largely rolled back or retuned.

---

## Scaling

??? question "Why doesn't iBGP full mesh scale?"
    n(n−1)/2 sessions — 50 routers is 1,225. Worse, adding one router means touching
    every existing one, so the change window grows with the network.

??? question "How does a route reflector work?"
    It's permitted to re-advertise iBGP-learned routes to its clients, so clients
    peer only with the reflector and sessions drop to roughly n. Only the reflector
    is configured; a client is an ordinary iBGP speaker, which makes deployment
    incremental.

??? question "What are the reflection rules?"
    From a **client** — reflect to other clients and to non-clients. From a
    **non-client** — reflect to clients only. From **eBGP** — to everyone. Because
    non-client routes aren't passed between non-clients, non-clients must still be
    fully meshed among themselves.

??? question "Without AS-path loop prevention, how does reflection avoid loops?"
    **ORIGINATOR_ID** carries the router ID of the original advertiser; a router
    seeing its own ID discards the route. **CLUSTER_LIST** records the clusters
    traversed; a reflector seeing its own cluster ID discards it. Both are optional
    non-transitive and never leave the AS.

??? question "Two reflectors — same cluster ID or different?"
    Same means they ignore each other's reflected routes, using less memory but
    offering clients fewer paths. Different means each treats the other's routes as
    new, giving better redundancy and path diversity at the cost of memory and
    duplicate updates. Different is the more common modern choice.

??? question "What does route reflection cost you?"
    **Path diversity.** A reflector advertises only its own best path, so clients see
    one path chosen from the reflector's IGP position rather than their own — which
    can be sub-optimal. `add-path` lets it advertise several, at the cost of memory.

??? question "Route reflectors or confederations?"
    Reflectors, essentially always. Both solve the mesh problem, but reflection
    deploys incrementally while confederations need an AS-numbering redesign.
    Confederations survive mainly where they were adopted early.

---

## Platform

??? question "Administrative distance of eBGP and iBGP?"
    Conventionally 20 and 200 — but that's Cisco IOS, not a standard. **Arista EOS
    defaults both to 200**, verified in [Lab 01](../lab-01-ebgp-ibgp.md). Give the
    conventional answer and note it's vendor-specific.
