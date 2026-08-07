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

## Area types: trading visibility for size

Not every area needs the full picture. If an area has one way out, telling its
routers about every external route in the world is wasted memory — they'd all
resolve to the same exit anyway.

So OSPF lets you **block LSA types at the ABR** and substitute a default route.
Each area type blocks a bit more:

| Area type | Blocks | Still gets | Use when |
|---|---|---|---|
| **Standard** | nothing | everything | the backbone, or areas needing full detail |
| **Stub** | type 5 (external) | types 1–4 + default | branch with one exit and no external sources |
| **Totally stubby** | types 3, 4, **5** | types 1–2 + default | same, but you also don't need inter-area detail |
| **NSSA** | type 5 | types 1–4 + **type 7** | stub area that *does* have its own external source |
| **Totally NSSA** | types 3, 4, 5 | types 1–2 + type 7 + default | NSSA that doesn't need inter-area detail either |

**Why NSSA exists** is the part people miss. A stub area cannot carry external
routes — that's the definition. But what if a stub-like area has a redistributing
router of its own? You'd have to make it standard and lose the savings.

NSSA solves it with **type 7**: functionally an external route, but permitted
inside an NSSA. The ABR translates type 7 into type 5 as it leaves. Same
information, different wrapper, because the area's rules forbid the type-5 wrapper.

!!! warning "Two rules that catch people out"
    **Every router in the area must agree on the area type.** It's negotiated in
    the hello, so a mismatch means no adjacency — the symptom is a neighbour that
    never forms, not a routing oddity.

    **Area 0 can never be a stub of any kind.** It carries transit for everything;
    blocking LSAs there would break inter-area routing by definition.

---

## Path preference: which route actually wins

When OSPF learns the same prefix more than once, it doesn't compare costs first.
It compares **route type** first, and only breaks ties within a type by cost:

```
intra-area  (O)      ← always wins, whatever the cost
inter-area  (O IA)
external E1 (O E1)
external E2 (O E2)   ← always loses
```

A high-cost intra-area route beats a low-cost inter-area one. Cost is the
tiebreaker *inside* a class, never across classes — a genuinely common exam trap.

### E1 vs E2 — the one everybody gets asked

Both are redistributed from outside OSPF. The difference is what happens to the
metric as it travels:

- **E2** — cost stays **fixed** at whatever the ASBR set, no matter how far you
  are from it. **This is the default.**
- **E1** — cost is the external metric **plus the internal cost** to reach the
  ASBR, so it rises with distance.

So with two exits to the same external destination, **E2 can't tell them apart** —
every router sees the same cost and picks by tiebreaker rather than by proximity.
**E1 can**, because each router adds its own distance to the ASBR.

!!! tip "The rule of thumb"
    **One exit — E2 is fine** and keeps the metric simple. **Multiple exits where
    you want routers to use the nearest — use E1.** Sticking with the E2 default in
    a multi-exit design is a classic cause of traffic crossing the network to reach
    a further-away exit.

---

## Router ID: how it's chosen

OSPF needs a unique 32-bit ID. It picks, in strict order:

1. **Manually configured** `router-id` — always wins
2. Highest IP on an **up loopback** interface
3. Highest IP on any **up physical** interface

**Always configure it explicitly.** Relying on the automatic choice means the ID
can change when an interface goes down or a new one appears — and since the router
ID is baked into every LSA that router originated, a change forces the entire area
to re-flood and re-run SPF.

A changed router ID also does *not* take effect until the OSPF process restarts,
which surprises people who set it and see nothing happen.

---

## Timers and cost

**Hello and dead intervals must match** between neighbours or the adjacency never
forms. Defaults depend on network type:

| Network type | Hello | Dead |
|---|---|---|
| Broadcast, point-to-point | **10s** | **40s** |
| NBMA, point-to-multipoint | **30s** | **120s** |

Dead is conventionally 4× hello. Lowering both speeds up failure detection, but for
sub-second convergence use **BFD** instead — a lightweight dedicated hello that
detects loss in milliseconds and tells OSPF to drop the neighbour, without the
overhead of very aggressive OSPF timers.

**Cost** is `reference bandwidth ÷ interface bandwidth`, default reference 100 Mbps.
That default is why every link at 100 Mbps *and above* lands on cost 1 — a 1G and a
100G link look identical to OSPF. Raise the reference bandwidth so modern speeds
differentiate, and **set it identically on every router**, since mismatched
reference bandwidths mean routers disagree about cost.

**Passive interface** advertises a network into OSPF while refusing to send hellos
on it. Correct for any interface with no OSPF neighbour — user-facing subnets,
loopbacks — since it removes needless adjacency attempts and a small attack surface.

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

## Summarisation, and where it's allowed

OSPF only summarises at **borders** — never arbitrarily, because routers inside an
area must hold identical databases and summarising mid-area would break that.

| Where | Command | Summarises |
|---|---|---|
| **ABR** | `area <id> range <prefix>` | inter-area (type 3) |
| **ASBR** | `summary-address <prefix>` | external (type 5 / 7) |

Mixing these up is a common interview stumble: `area range` on an ASBR does nothing
to external routes, and `summary-address` on an ABR does nothing to inter-area ones.

Summarisation is the main defence against a large OSPF domain becoming unstable: a
link flapping behind a summary doesn't change the summary, so the flap stays local
instead of forcing SPF runs network-wide. The cost is lost visibility, and
potentially attracting traffic for addresses inside the range that aren't actually
reachable.

## Virtual links: the escape hatch

Every area must touch area 0 — but occasionally one doesn't, usually after a merger
or a backbone that got physically split. A **virtual link** tunnels through an
intervening area to restore the connection:

```
interface Ethernet1
 ...
router ospf 1
 area 0.0.0.1 virtual-link 4.4.4.4
```

The transit area must be standard (never stub, which can't carry the necessary
LSAs) and cannot be area 0 itself.

!!! warning "Treat a virtual link as a repair, not a design"
    It works, and it's the right tool in an emergency. But it's fragile — it depends
    on the transit area staying healthy — and it hides a structural problem in the
    address plan. If a virtual link is load-bearing in your network, the real fix is
    re-homing that area to the backbone.

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
topology only; prefixes travel in separate LSAs (Link LSAs and Intra-Area-Prefix LSAs). This is what makes OSPFv3 able to
carry address families other than the one it was designed around.

**Authentication was removed** from the protocol and delegated to IPsec — a cleaner
design in theory, more operationally awkward in practice.

---

### Arista cEOS OSPFv3 Configuration

Configuring OSPFv3 on Arista cEOS requires enabling IPv6 routing, assigning a manual 32-bit router-ID, and binding interfaces to the OSPFv3 process ID:

```eos
! Enable IPv6 unicast routing globally
ipv6 unicast-routing

! Define the OSPFv3 process (Process ID 100) and explicit Router ID
router ospf3 100
   router-id 1.1.1.1
   exit

! Loopback interface configuration
interface Loopback0
   ipv6 address 2001:db8:1::1/128
   ipv6 ospf 100 area 0.0.0.0

! Point-to-point inter-router link
interface Ethernet1
   no switchport
   ipv6 address 2001:db8:12::1/64
   ipv6 ospf 100 area 0.0.0.0
   ipv6 ospf network point-to-point
```

!!! note "Process ID requirement in interface syntax"
    Unlike OSPFv2 (`ip ospf area 0.0.0.0`), OSPFv3 interface configuration requires the process ID explicitly: `ipv6 ospf <process-id> area <area-id>`.

---

### OSPFv3 Operational Verification

Verify adjacency, link states, and IPv6 routes using dedicated `ipv6` CLI commands:

```bash
# Check OSPFv3 adjacencies (note neighbour IP is link-local fe80::)
docker exec clab-ceos-r1 Cli -p 15 -c "show ipv6 ospf neighbor"

# Verify IPv6 routes installed by OSPFv3
docker exec clab-ceos-r1 Cli -p 15 -c "show ipv6 route ospf"
```

Sample output of `show ipv6 ospf neighbor`:
```
Neighbor ID     Instance VRF      Pri State                  Dead Time   Address       Interface
2.2.2.2         100      default  1   FULL/P2P               00:00:34    fe80::2       Ethernet1
```

Sample output of `show ipv6 route ospf`:
```
Codes: C - connected, S - static, K - kernel,
       O - OSPF, IA - OSPF inter area, E1 - OSPF external type 1,
       E2 - OSPF external type 2

O        2001:db8:2::2/128 [110/20] via fe80::2, Ethernet1
```

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
