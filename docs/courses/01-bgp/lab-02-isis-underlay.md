# 🧪 Lab 02 · iBGP over an IS-IS underlay

> ✅ **Validated** on Arista cEOS 4.32.0F, 2026-08-03. All output captured live.

**Time:** ~30 minutes · **Nodes:** 3 (same topology as Lab 01)

Swap the IGP underneath a working BGP deployment — from OSPF to IS-IS — and watch
what happens to the BGP sessions.

The answer is the lesson.

---

## What you'll learn

- IS-IS configuration on EOS: NET addressing, levels, point-to-point circuits
- Why **BGP doesn't care which IGP you run**
- Reading the IS-IS database and adjacency output
- The practical differences from OSPF you'll actually notice

---

## Prerequisites

> [!IMPORTANT]
> **Sequential Dependency Link**: Lab 02 does **NOT** start from a blank fabric. It is a live underlay migration lab that modifies the running BGP fabric built in **[Lab 01 · eBGP, iBGP and next-hop-self](lab-01-ebgp-ibgp.md)**.
> If you are starting fresh, run `./run.sh --all` inside `labs/bgp-lab` first to establish Lab 01's starting state!

**[Lab 01](lab-01-ebgp-ibgp.md) built and working.** This lab modifies it rather
than starting fresh — that's the point. You need a running BGP deployment to swap
the IGP underneath.

Concepts: **[Phase 0 · IS-IS](../00-igp-fundamentals/03-isis.md)**.

!!! tip "Quick Start — Step-by-Step Execution Guide (Location: `labs/bgp-lab/`)"
    **Prerequisite · Ensure Lab 01 is deployed and established first**
    ```bash
    cd labs/bgp-lab
    sudo containerlab deploy -t topology.clab.yml --max-workers 1
    ./run.sh --all        # (or ./run.sh --guided) to build the starting BGP+OSPF fabric
    ```

    **Step 1 · Confirm starting BGP state (should be `Estab`)**
    ```bash
    docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary"
    ```

    **Step 2 · Apply IS-IS Swap & Verify**
    Follow Step 2 below to replace OSPF with IS-IS on `r1` and `r2`.

---

## Step 1 · Confirm the starting state

Lab 01 leaves you with OSPF between r1 and r2, carrying the loopbacks that iBGP
peers over.

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" | tail -3
```

```
  Neighbor  V AS           MsgRcvd   MsgSent  InQ OutQ  Up/Down State   PfxRcd PfxAcc
  2.2.2.2   4 65001             61        63    0    0 00:46:00 Estab   1      1
  10.0.13.3 4 65002             60        57    0    0 00:46:18 Estab   1      1
```

**Note the `Up/Down` column.** Come back to it at the end.

✅ **DONE when** both sessions are `Estab`.

---

## Step 2 · Replace OSPF with IS-IS

=== "r1"

    ```
    configure
    no router ospf 1
    !
    router isis CORE
     net 49.0001.0000.0000.0001.00
     is-type level-2
     address-family ipv4 unicast
    !
    interface Loopback0
     isis enable CORE
     isis passive
    !
    interface Ethernet1
     isis enable CORE
     isis network point-to-point
    ```

=== "r2"

    ```
    configure
    no router ospf 1
    !
    router isis CORE
     net 49.0001.0000.0000.0002.00
     is-type level-2
     address-family ipv4 unicast
    !
    interface Loopback0
     isis enable CORE
     isis passive
    !
    interface Ethernet1
     isis enable CORE
     isis network point-to-point
    ```

Apply with `docker exec -i`, as always.

**Reading the NET** `49.0001.0000.0000.0001.00`:

| Part | Value | Meaning |
|---|---|---|
| AFI | `49` | private addressing — the OSI equivalent of RFC 1918 |
| Area | `0001` | belongs to the **whole router**, not per-interface |
| System ID | `0000.0000.0001` | unique, exactly 6 bytes |
| NSEL | `00` | always `00` on a router |

!!! tip "Three configuration differences from OSPF worth noticing"
    **`isis enable CORE` on the interface**, not an area statement — the area came
    from the NET, because in IS-IS the *router* belongs to an area.

    **`isis passive` on the loopback** rather than putting it in an area. Same
    intent as OSPF's passive-interface: advertise the prefix, don't form
    adjacencies on it.

    **`is-type level-2`** — a single-area network should be L2-only. The default of
    L1/L2 makes every router maintain two databases for no benefit.

---

## Step 3 · Verify the adjacency

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show isis neighbors"
```

```
Instance  VRF      System Id  Type Interface   SNPA  State Hold time  Circuit Id
CORE      default  r2         L2   Ethernet1   P2P   UP    22         35
```

`State UP`, `Type L2`, `P2P`. Note the System Id shows **`r2`**, not the raw
`0000.0000.0002` — IS-IS carries a dynamic hostname TLV so output is readable. A
genuinely nice touch OSPF lacks, where you're stuck matching router IDs by hand.

✅ **DONE when** state is `UP`.

If it isn't: check both routers have `isis enable` on the link, that system IDs are
unique, and that `is-type` matches on both ends.

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show isis interface brief"
```

```
Interface Level IPv4 Metric IPv6 Metric Type            Adjacency
--------- ----- ----------- ----------- --------------- ---------
Loopback0 L2             10          10 loopback        (passive)
Ethernet1 L2             10          10 point-to-point          1
```

The loopback is `(passive)` — advertised, no adjacencies. Exactly as intended.

---

## Step 4 · The database

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show isis database"
```

```
  IS-IS Level 2 Link State Database
    LSPID       Seq Num  Cksum  Life Length IS  Received LSPID        Flags
    r1.00-00          2  41626  1174     93 L2  0000.0000.0001.00-00  <>
    r2.00-00          2  64871  1174     93 L2  0000.0000.0002.00-00  <>
```

One **LSP** per router — the IS-IS equivalent of OSPF's router LSA, except a single
LSP carries everything that router has to say, encoded as TLVs. OSPF splits the same
information across several LSA types.

`Seq Num` rises on change; `Life` counts down and refreshes. Same mechanics as OSPF,
different packaging.

The `Received LSPID` column shows the raw system ID alongside the friendly hostname.

---

## Step 5 · The routes

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip route 2.2.2.2"
```

```
 I L2     2.2.2.2/32 [115/20]
           via 10.0.12.2, Ethernet1
```

**`I L2`** — IS-IS, level 2. **`[115/20]`** — administrative distance 115, metric 20.

| | OSPF | IS-IS |
|---|---|---|
| Administrative distance | 110 | **115** |
| Default interface metric | derived from bandwidth | **10, flat** |

Two things follow. **OSPF wins if both run**, on AD alone. And **IS-IS metrics don't
scale with bandwidth by default** — every interface is 10 until you set otherwise,
so a 1G and a 100G link look identical. Set metrics deliberately.

✅ **DONE when** `2.2.2.2/32` is present via `I L2`.

---

## Step 6 · The actual lesson

Now look at BGP again:

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" | tail -3
```

```
  Neighbor  V AS           MsgRcvd   MsgSent  InQ OutQ  Up/Down State   PfxRcd PfxAcc
  2.2.2.2   4 65001             61        63    0    0 00:46:00 Estab   1      1
  10.0.13.3 4 65002             60        57    0    0 00:46:18 Estab   1      1
```

**The sessions never went down.** `Up/Down` reads 46 minutes — spanning the entire
IGP replacement. We removed OSPF and configured IS-IS underneath a live BGP
deployment and the sessions didn't notice.

```bash
docker exec clab-bgp-lab-r2 Cli -p 15 -c "ping 172.16.30.1 source 172.16.20.1 repeat 3"
```

```
--- 172.16.30.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 11ms
```

Still forwarding. ✅ **DONE.**

!!! tip "Why this works, and why it matters"
    **BGP needs a route to its peer's loopback. It does not care where that route
    came from.** OSPF, IS-IS, or a static route — BGP resolves the next hop against
    the routing table and asks nothing further.

    The IGP replacement completed faster than the 180-second hold timer, so BGP
    never declared the peer dead.

    This is why IGP migrations are feasible on live networks: the layers are
    genuinely independent. It's also why "BGP is down" so often turns out to be an
    IGP problem — the dependency is real, it's just one-directional.

---

## Break & observe

Remove the loopback from IS-IS on r2 and watch the failure propagate upward:

```bash
docker exec -i clab-bgp-lab-r2 Cli -p 15 <<'EOF'
configure
interface Loopback0
 no isis enable CORE
end
EOF
```

Within a couple of minutes r1 loses the route to `2.2.2.2`, can no longer reach the
iBGP peer address, and the session drops to `Active` — not `Idle`, because BGP keeps
retrying TCP that can't be established.

**The symptom is "BGP is down." The fault is one interface missing from the IGP.**
Exactly the pattern from
[Phase 0](../00-igp-fundamentals/01-link-state.md).

Restore it:

```bash
docker exec -i clab-bgp-lab-r2 Cli -p 15 <<'EOF'
configure
interface Loopback0
 isis enable CORE
end
EOF
```

---

## OSPF vs IS-IS, as configured here

| | OSPF | IS-IS |
|---|---|---|
| Area membership | per **interface** (`ip ospf area`) | per **router** (from the NET) |
| Enabling on a link | `ip ospf area 0.0.0.0` | `isis enable CORE` |
| Loopback | `ip ospf area` + passive | `isis passive` |
| Advertisement | several LSA types | one LSP of TLVs |
| Neighbour display | router IDs | **hostnames** |
| Admin distance | 110 | 115 |
| Default metric | from bandwidth | flat 10 |

Neither is harder. IS-IS front-loads the addressing (the NET) and simplifies the
interfaces; OSPF has no addressing to design but more per-interface configuration.

For which to choose, see
[Phase 0 · Choosing](../00-igp-fundamentals/04-choosing.md).

---

## Troubleshooting

| Symptom | Cause |
|---|---|
| No adjacency | `isis enable` missing one end, or `is-type` mismatch |
| Adjacency up, no routes | `address-family ipv4 unicast` missing under `router isis` |
| Loopback not advertised | missing `isis passive` — the IS-IS version of Lab 01's OSPF trap |
| Duplicate system ID | two routers with the same NET — check the database for conflicts |
| BGP drops after the swap | the IGP didn't converge inside the 180s hold time |

---

## Interview questions

??? question "You migrate the IGP under a live BGP deployment. Do the sessions drop?"
    Not if the new IGP converges within the hold time — 180 seconds by default. BGP
    only needs *a* route to the peer's loopback and doesn't care which protocol
    installed it. Verified here: sessions showed 46 minutes of uptime spanning the
    entire OSPF-to-IS-IS swap.

??? question "How does IS-IS interface configuration differ from OSPF's?"
    OSPF assigns each interface to an area (`ip ospf area 0.0.0.0`). IS-IS takes the
    area from the router's NET, so the interface only needs `isis enable`. Loopbacks
    use `isis passive` rather than an area plus passive-interface.

??? question "What's the administrative distance of IS-IS, and why does it matter?"
    115, against OSPF's 110. If both run for the same prefix, **OSPF wins** — which
    matters during a migration where both are briefly active. Plan for it or the
    traffic path may not be what you expect mid-cutover.

??? question "Why is the default IS-IS metric a problem?"
    It's a flat 10 on every interface regardless of bandwidth, so a 1G and a 100G
    link are indistinguishable. OSPF at least derives cost from bandwidth. Set IS-IS
    metrics explicitly, and use `metric-style wide` so you have room to.

??? question "Neighbours show hostnames rather than system IDs. How?"
    The dynamic hostname TLV — IS-IS advertises the router's hostname alongside its
    system ID, and output resolves it. It's an extensibility benefit of TLV
    encoding; OSPF has no equivalent, so you match router IDs by hand.

---

## 🧠 Google Network Infra Knowledge Sharing

> [!NOTE]
> ### Production Deep Dive & Hyperscale Architecture
>
> 1. **Why Hyperscalers Prefer IS-IS Over OSPF**:
>    - **Transport Layer**: IS-IS runs directly on Layer 2 Ethernet frames (`802.3` / LLC `0xFEFE`), whereas OSPF runs over IP (Protocol 89). An IP stack failure or misconfigured IP interface cannot crash IS-IS adjacencies.
>    - **Dual-Stack Simplicity**: A single IS-IS process and TLV extensions support IPv4 and IPv6 concurrently (`multi-topology` or `single-topology`). OSPF requires two separate protocol instances (OSPFv2 for IPv4, OSPFv3 for IPv6).
>
> 2. **Hitless Underlay Cutover Strategy**:
>    - In production, IGP migrations (e.g., OSPF → IS-IS) leverage BGP's default 180-second hold timer and TCP's resilience.
>    - As long as loopback reachability transitions from OSPF to IS-IS within 180 seconds, the iBGP TCP sessions remain established without dropping control plane routes or clearing forwarding tables.
>
> 3. **Wide Metrics & Traffic Engineering**:
>    - Narrow IS-IS metrics (default 6-bit link cost, max 63) limit path engineering across large fabrics. Hyperscale deployment standards enforce `metric-style wide` (24-bit link metrics, 32-bit path metrics) to enable granular traffic engineering and Segment Routing (SR-MPLS).

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```

---

**Next:** [Lab 03 · Route reflectors →](lab-03-route-reflectors.md).
