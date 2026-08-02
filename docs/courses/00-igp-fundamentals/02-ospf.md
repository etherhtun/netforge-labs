# 2 · OSPF

OSPF is the IGP most enterprises run, and the one every later phase in this
curriculum quietly depends on. This page covers what actually matters in practice —
plus where OSPFv3 diverges for IPv6.

> The command output below was captured from a **live three-router cEOS fabric**,
> not written from memory.

---

## Areas: the organising idea

OSPF splits a network into **areas**, and every area must touch **area 0** — the
backbone. Traffic between two non-backbone areas always transits area 0.

That constraint feels arbitrary until you see what it prevents: without a single
mandatory hub, inter-area routing would need loop prevention between areas, and
OSPF deliberately doesn't have one. The rigid hub-and-spoke *is* the loop
prevention.

Routers get named by where they sit:

| Role | Position |
|---|---|
| **Internal** | all interfaces in one area |
| **ABR** (Area Border Router) | interfaces in two or more areas — one must be area 0 |
| **ASBR** (AS Boundary Router) | injects external routes into OSPF |

!!! note "Area membership is per-interface"
    A router isn't "in" an area — each of its *interfaces* is. This is a real
    difference from IS-IS, where the whole router belongs to a level, and it's a
    common interview question.

Here's a single-area fabric — note `Area 0.0.0.0` on each interface:

```
   Interface          Instance VRF        Area            IP Address         Cost  State      Nbrs
   Et2                1        default    0.0.0.0         10.1.2.1/24        10    P2P        1
   Et1                1        default    0.0.0.0         10.1.1.1/24        10    P2P        1
   Lo0                1        default    0.0.0.0         1.1.1.1/32         10    DR         0
```

---

## LSA types: who advertises what

The LSDB isn't one kind of record. Different situations produce different **LSA
types**, and knowing the common ones turns database output from noise into
information.

| Type | Name | Says |
|---|---|---|
| **1** | Router | "here are my links and their costs" — every router, within its area |
| **2** | Network | "here's who's on this multi-access segment" — from the DR |
| **3** | Summary | "this prefix exists in another area" — from an ABR |
| **4** | ASBR Summary | "here's how to reach the ASBR" — from an ABR |
| **5** | External | "here's a route from outside OSPF" — from an ASBR |
| **7** | NSSA External | like type 5, but inside a not-so-stubby area |

Types 1 and 2 stay **within** an area. That's the containment that makes areas
worth having — topology detail never leaves.

Real Router LSAs from the fabric, one per router, each with a sequence number and
age:

```
                 Router Link States (Area 0.0.0.0)

Link ID         ADV Router      Age         Seq#         Checksum Link count
2.2.2.2         2.2.2.2         120         0x80000006   0x6556   3
3.3.3.3         3.3.3.3         1811        0x80000005   0xbfee   3
1.1.1.1         1.1.1.1         169         0x80000008   0xbaae   5
```

Read it as: three routers, each describing itself. `Link count` is how many links
that router is advertising. `Seq#` rises on every change — a rapidly climbing
sequence number means something is flapping.

---

## Adjacency: the state machine

Two OSPF routers walk through defined states before exchanging routes. Knowing
where it stalls tells you the cause immediately.

```mermaid
graph LR
    D["Down"] --> I["Init"] --> T["2-Way"] --> E["ExStart"] --> X["Exchange"] --> L["Loading"] --> F["Full"]
    classDef progress fill:#1565c0,stroke:#90caf9,color:#ffffff,stroke-width:2px,font-size:15px;
    classDef working fill:#2e7d32,stroke:#a5d6a7,color:#ffffff,stroke-width:2px,font-size:15px;
    class D,I,T,E,X,L progress; class F working;
```

- **Init** — I heard a hello, but didn't see myself in it yet.
- **2-Way** — we can both see each other. On a LAN, routers that aren't the DR or
  BDR *stop here on purpose*, and that's healthy.
- **ExStart / Exchange** — deciding who leads, then describing databases.
- **Loading** — requesting the details each side is missing.
- **Full** — databases synchronised. **This is the only state that means working.**

**Where it sticks, and why:**

| Stuck at | Cause |
|---|---|
| **Init** | one-way hellos — filtering, or an ACL dropping multicast |
| **2-Way** *(non-LAN)* | DR election problem, or both routers have priority 0 |
| **ExStart / Exchange** | **MTU mismatch** — the classic. Each side sends a database packet the other can't accept |
| Flapping in and out of Full | mismatched dead intervals, or an unstable link |

A healthy pair looks like this:

```
Neighbor ID     Instance VRF      Pri State                  Dead Time   Address         Interface
3.3.3.3         1        default  0   FULL                   00:00:38    10.1.2.2        Ethernet2
2.2.2.2         1        default  0   FULL                   00:00:38    10.1.1.2        Ethernet1
```

`Dead Time` counts down and resets on every hello. If you watch it approach zero,
hellos aren't arriving.

---

## Network types, DR, and why point-to-point is better

On a shared segment with *n* routers, forming a full mesh of adjacencies means
`n(n-1)/2` relationships — wasteful and noisy. OSPF elects a **Designated Router**
that everyone adjoins instead, plus a **BDR** standing by.

Election is by priority, highest wins, router-ID breaking ties. Priority `0` means
"never elect me."

**But most modern links are point-to-point.** Two routers on a routed link have
nothing to elect, and DR election just adds delay. Hence:

```
interface Ethernet1
 no switchport
 ip address 10.1.1.1 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
```

Notice `State P2P` and `Nbrs 1` in the interface output earlier — no DR involved.

!!! tip "Set point-to-point on routed links between two routers"
    It skips DR election, forms adjacency faster, and produces a simpler database
    (no type-2 LSA). On a spine-leaf fabric where every link is a routed
    point-to-point, this should be your default.

    The loopback still shows `DR` — that's normal and harmless. A loopback has no
    neighbours to elect anything with.

---

## OSPFv3: what changes for IPv6

OSPFv3 is the same algorithm with meaningfully different plumbing.

**Per-link, not per-subnet.** OSPFv2 forms adjacencies with routers in the same
IP subnet. OSPFv3 works per *link* — addressing doesn't gate neighbour formation.
Multiple prefixes on one link stop being a problem.

**Neighbours are link-local.** Adjacencies use `fe80::` addresses. Peers appear as
link-local even though they carry global prefixes — that's correct, not a
misconfiguration.

**Router IDs are still 32-bit.** Written in dotted-quad form, exactly like IPv4.
In an IPv6-only network there's no address to derive one from, so **you must set
it manually** — a genuinely common cause of OSPFv3 refusing to start.

**Addressing moved out of the topology LSAs.** Router and network LSAs describe
topology only; prefixes travel in separate LSAs. This is what makes OSPFv3 able to
carry address families other than the one it was designed around.

**Authentication was removed** from the protocol and delegated to IPsec — a cleaner
design in theory, more operationally awkward in practice.

!!! warning "v2 and v3 are separate protocols, not one protocol with two modes"
    Running dual-stack means running **two independent OSPF instances** with two
    databases and two SPF computations. They can disagree: IPv4 taking one path and
    IPv6 another across the same physical topology is entirely possible, and
    debugging it means checking both.

    IS-IS handles this differently — see [choosing](04-choosing.md).

---

## Interview questions

??? question "Why must every OSPF area connect to area 0?"
    OSPF has no loop-prevention mechanism *between* areas — inter-area routes are
    distance-vector-like summaries, and a router can't see the topology behind
    them. Forcing all inter-area traffic through a single backbone makes loops
    structurally impossible instead of algorithmically prevented.

??? question "Two routers are stuck in ExStart/Exchange. What do you check first?"
    **MTU.** During database exchange each side sends packets sized to its own MTU;
    if the other can't receive them, the exchange never completes. The interfaces
    are up and hellos work fine, which is what makes it confusing — small packets
    pass, large ones don't.

??? question "A router on a LAN is stuck at 2-Way. Is it broken?"
    Probably not. On a multi-access segment only the DR and BDR go to Full —
    everyone else deliberately stays at 2-Way with each other. It's a problem only
    if the router should have become DR or BDR and didn't.

??? question "What's the practical difference between OSPFv2 and OSPFv3 areas?"
    Conceptually none — the area model is identical. The differences are in
    transport and encoding: v3 is per-link rather than per-subnet, peers over
    link-local addresses, separates addressing from topology LSAs, and drops
    built-in authentication in favour of IPsec.

??? question "Why prefer point-to-point over broadcast on a routed link?"
    There's nothing to elect with only two routers, so DR election adds startup
    delay for no benefit. Point-to-point forms adjacency faster and keeps the
    database simpler by omitting the type-2 network LSA.

---

**Next:** [IS-IS →](03-isis.md) — the same job, a very different design, and the
reason providers keep choosing it.
