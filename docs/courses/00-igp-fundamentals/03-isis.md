# 3 · IS-IS

IS-IS does the same job as OSPF and does it with the same algorithm. What differs
is the design philosophy — and those differences are exactly why large service
providers keep choosing it.

!!! note "No live output on this page"
    The OSPF page shows real captured output because a fabric was running it.
    Nothing here has been run on live equipment yet, so this page shows **syntax and
    concepts only** — no invented command output. Sample output will be added when
    an IS-IS lab is built.

---

## The thing that surprises everyone first

**IS-IS doesn't run over IP.** It runs directly on layer 2, as its own protocol.

OSPF is carried inside IP packets — protocol 89. IS-IS isn't inside anything; it's
a peer of IP rather than a passenger.

Two real consequences follow:

- **It's much harder to attack remotely.** You cannot route a packet to an IS-IS
  process from across the internet, because there's no IP header to route. An
  attacker needs to be on the link.
- **It doesn't depend on the thing it's building.** IS-IS never has the awkward
  circularity of using IP to establish IP reachability.

This is a genuine security and robustness argument, and it's part of why providers
like it for backbone networks.

---

## Addressing: the NET

IS-IS predates its use for IP. It came from the OSI protocol suite, and it still
identifies routers using OSI-style addressing — the **NET** (Network Entity Title).

```
router isis CORE
 net 49.0001.0000.0000.0001.00
```

Broken apart:

| Part | Value | Meaning |
|---|---|---|
| AFI | `49` | private addressing — the equivalent of RFC 1918 |
| Area ID | `0001` | which area this **router** belongs to |
| System ID | `0000.0000.0001` | unique router identifier, 6 bytes |
| NSEL | `00` | always `00` for a router |

Two practical notes that trip people up:

- **The system ID must be unique** across the domain, and it must be exactly 6
  bytes. A common convention encodes the loopback: `1.1.1.1` becomes
  `0010.0100.1001`, padding each octet to three digits.
- **The area is a property of the router, not the interface.** This is the
  clean opposite of OSPF, and it means a router cannot have interfaces in two
  different areas.

---

## Levels instead of areas

IS-IS has two levels of hierarchy:

| Level | Role | OSPF analogue |
|---|---|---|
| **L1** | intra-area — knows its own area in detail | non-backbone area |
| **L2** | inter-area — forms the backbone | area 0 |
| **L1/L2** | both — the border between them | ABR |

The critical structural difference: **the L2 backbone is a contiguous chain of L2
routers, not a numbered area.** It doesn't have to be "area 0" — it just has to be
connected.

That flexibility matters. Extending an OSPF backbone means extending area 0, often
with virtual links when the topology doesn't cooperate. Extending an IS-IS backbone
means enabling L2 on some more routers. Providers who grow by acquisition find this
much less painful.

An L1 router reaching outside its area sends traffic to the nearest L1/L2 router,
which sets a bit advertising itself as an exit. The L1 router doesn't need to know
what's out there — just who to hand it to.

---

## TLVs: why IS-IS aged so well

IS-IS encodes everything as **TLVs** — Type, Length, Value. A router that meets a
TLV type it doesn't recognise skips it cleanly using the length field and carries
on.

This sounds like a minor encoding detail. It's the most consequential design
decision in the protocol.

**Adding a capability doesn't require a new protocol version.** You define a new
TLV. Old routers ignore it, new ones use it, and the network keeps running through
the transition.

Which is why:

- **IPv6 support** was a new TLV. OSPF needed OSPFv3 — effectively a new protocol.
- **Segment routing** landed on IS-IS first and most naturally. SIDs are TLVs.
- **Traffic engineering** extensions arrived the same way.

If you plan to run segment routing, this is a real argument for IS-IS rather than a
matter of taste.

---

## Adjacency and the DIS

IS-IS uses **hello PDUs** to find neighbours, and it's stricter than OSPF about one
thing: an L1 adjacency requires **matching area IDs**, while L2 adjacencies form
regardless of area.

On a LAN, IS-IS elects a **DIS** (Designated Intermediate System) — similar in
spirit to OSPF's DR, but with two differences worth knowing:

- **There's no backup.** If the DIS fails, a new election simply happens. IS-IS
  elections are fast enough that a standby isn't considered worth the complexity.
- **The DIS can be pre-empted.** A higher-priority router arriving later *takes
  over*. OSPF's DR deliberately holds its position to avoid churn.

The units flooded are **LSPs** (Link State PDUs), the direct analogue of OSPF's
LSAs — and unlike OSPF's several LSA types, one LSP carries everything that router
has to say, as TLVs.

---

## Metrics: mind the narrow default

Original IS-IS allocated only **6 bits** to interface metrics — a maximum of 63,
with total path cost capped at 1023. That was generous in 1990 and is unusable now.

**Wide metrics** (32 bits, via a TLV) fixed it:

```
router isis CORE
 metric-style wide
```

!!! warning "Set wide metrics before you need them"
    Mixing narrow and wide metrics in one domain causes routers to disagree about
    path cost — and routers that disagree about cost compute different trees, which
    is how a link-state protocol ends up with a loop.

    Wide metrics are also a **prerequisite for segment routing and traffic
    engineering**, since those extensions carry information narrow metrics have no
    room for. Configure it on day one.

---

## Dual-stack: single vs multi-topology

Because IPv6 arrived as a TLV, one IS-IS instance can carry IPv4 and IPv6 together.
There are two ways to do that, and choosing wrongly causes subtle breakage.

**Single topology** — one SPF computation, one set of paths, both address families
following it. Simple and efficient, but it assumes **every link carries both
protocols**. A link that's IPv4-only will still be used for IPv6, and that traffic
will black-hole.

**Multi-topology (MT)** — separate SPF per address family, so IPv4 and IPv6 can
legitimately take different paths across a partially-deployed network.

```
router isis CORE
 net 49.0001.0000.0000.0001.00
 metric-style wide
 !
 address-family ipv6 unicast
  multi-topology
```

Use single topology only when your dual-stack deployment is genuinely complete and
you intend to keep it that way. Otherwise MT is the safe choice.

Either way this is still **one protocol instance** — as against OSPF, where dual
stack means running v2 and v3 as two separate protocols with two databases.

---

## Interview questions

??? question "Why do providers favour IS-IS over OSPF in the backbone?"
    Three reasons that compound. It runs directly on layer 2, so it can't be
    attacked from off-link. TLV encoding means new capabilities — IPv6, segment
    routing, TE — arrive as extensions rather than protocol rewrites. And the L2
    backbone is a contiguous set of routers rather than a numbered area, which
    makes growing or merging networks far less disruptive.

??? question "What is a NET, and which part actually identifies the router?"
    The Network Entity Title, an OSI-style address. The **system ID** — six bytes
    in the middle — identifies the router and must be unique domain-wide. The area
    ID sits before it, and the trailing NSEL is always `00` on a router.

??? question "How does IS-IS area membership differ from OSPF's?"
    IS-IS assigns the **whole router** to an area; OSPF assigns each **interface**.
    So an IS-IS router can't straddle two areas the way an OSPF ABR does — the
    equivalent role is a router running both L1 and L2.

??? question "Why does metric-style wide matter beyond just bigger numbers?"
    Narrow metrics cap at 63 per link, which no longer expresses modern bandwidth
    differences. More importantly, wide metrics are carried in TLVs with room for
    extra information, making them a **prerequisite for segment routing and traffic
    engineering**. Mixing styles also causes cost disagreements between routers.

??? question "When would single-topology dual-stack be the wrong choice?"
    Whenever IPv4 and IPv6 aren't enabled on every link. Single topology computes
    one tree for both, so IPv6 traffic can be sent down a link that only carries
    IPv4 and black-hole. Multi-topology computes a separate tree per family and
    avoids it.

---

**Next:** [Choosing between them →](04-choosing.md) — an honest comparison and how
to approach dual-stack.
