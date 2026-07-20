# Session 6 — ESI Multihoming (all-active dual-homing)

> **Goal:** connect a host to **two leaves at once**, both links active, so it
> survives a leaf or link failure *and* uses both uplinks for bandwidth. This is
> **EVPN multihoming** via an **Ethernet Segment (ESI)** — the modern, standards-
> based replacement for vendor tricks like vPC/MC-LAG.

*Prerequisite: L2VNI (Session 3) — multihoming is about how a host attaches to the
fabric.*

---

## 1. Mental model

A single-homed host has **one door** into the fabric — one leaf. If that leaf (or
its cable) fails, the host is cut off. A **single point of failure.**

Multihoming gives the host **two doors** into **two different leaves**, and it can
use **both at once** (all-active). To the host it looks like one bonded link; to
the fabric, the two leaf-ports form **one shared Ethernet Segment**. If one door
closes, the resident just uses the other — no outage.

The catch with two doors: when the mail carrier delivers a **broadcast** (BUM
traffic) to the segment, exactly **one** door must accept it, or the resident gets
duplicate copies. So the two leaves elect a **Designated Forwarder (DF)** — the one
that delivers BUM to that segment.

---

## 2. Why before how

**Why multihome?**
Two reasons: **resilience** (a leaf/link failure doesn't isolate the host) and
**bandwidth** (all-active uses both uplinks, not one active + one idle). Any host
that matters — a hypervisor, a storage node — should be dual-homed.

**Why EVPN multihoming instead of MC-LAG / vPC?**
Legacy dual-homing (vPC, MC-LAG) needs a special peer-link and proprietary state
sync between exactly two switches. **EVPN multihoming is standards-based, needs no
peer-link, and isn't limited to pairs** — the Ethernet Segment concept scales and
interoperates across vendors. It's the modern approach.

**Why is a Designated Forwarder needed?**
Because both leaves can reach the host, a BUM frame flooded to the segment would
arrive twice. The DF election picks one leaf to forward BUM *per segment per VLAN*,
so the host sees exactly one copy. Unicast is unaffected (it's load-balanced).

---

## 3. The mechanism (technical depth)

### The Ethernet Segment and its ESI
The set of links from the two leaves to the *same* multihomed host is one
**Ethernet Segment**, identified by a 10-byte **ESI** configured **identically on
both leaves**. Same ESI = "these ports lead to the same host." The leaves also
present the **same LACP system-id** so the host's LACP bond sees them as one
partner and forms a single aggregate.

### All-active vs single-active
- **All-active:** the host load-balances across both uplinks; both leaves forward
  its traffic. (What we build.)
- **Single-active:** only one leaf is active at a time (used when the host can't
  bond, e.g. simple failover). Less common.

### The route types that make it work
- **Type-4 (Ethernet Segment route):** the two leaves discover they share the ESI
  and **elect the DF** (who forwards BUM to the segment). One Type-4 per leaf per ES.
- **Type-1 (Ethernet Auto-Discovery):**
  - *per-ES* — **fast withdrawal**: on a link failure, the leaf withdraws this one
    route and *all* the host's MACs behind that ES are invalidated instantly, far
    faster than withdrawing thousands of Type-2s individually.
  - *per-EVI* — **aliasing**: lets remote VTEPs **load-balance** unicast to the
    host across *both* leaves, even though only one leaf may have advertised the
    host's Type-2. The remote leaf sees "this MAC is on ESI X, and ESI X is
    reachable via leaf1 *and* leaf2" → ECMP to the host.
- **Type-2 (MAC/IP):** as always, advertises the host's MAC — now tagged with the ESI.

### Split-horizon (no echo)
When the DF floods BUM onto the segment, the *other* leaf must not send that same
frame back to the host (it already got it). EVPN uses a **split-horizon / local-bias**
rule (ESI label / source filtering) so a multihomed host never receives its own
flooded frame back.

### Putting it together
Host bonds two links (LACP) → both leaves share one ESI + system-id → Type-4 elects
a DF for BUM → Type-1 per-ES gives fast failover, per-EVI gives aliasing (load-
balance) → Type-2 advertises the MAC on the ESI. Lose a link: the leaf withdraws
its Type-1 per-ES, remote VTEPs instantly shift all that host's traffic to the
surviving leaf. Sub-second, no flooding.

---

## 4. Build it

New lab: **[Lab 05 — ESI multihoming](../labs/lab-05-esi.md)**. host1 is dual-homed
to leaf1 **and** leaf2 as an LACP bond; host2 (single-homed) tests reachability.

**Config sketch — the Ethernet Segment (identical on leaf1 and leaf2):**
```
set interfaces ge-0/0/2 ether-options 802.3ad ae0
set interfaces ae0 esi 00:11:22:33:44:55:66:77:88:99      # SAME on both leaves
set interfaces ae0 esi all-active
set interfaces ae0 aggregated-ether-options lacp active
set interfaces ae0 aggregated-ether-options lacp system-id 00:00:5e:00:53:01  # SAME on both
set interfaces ae0 unit 0 family ethernet-switching interface-mode access
set interfaces ae0 unit 0 family ethernet-switching vlan members v100
```
The **same ESI and same LACP system-id on both leaves** is the whole trick — it's
what makes two ports on two switches behave as one Ethernet Segment / one bond.
Full per-node config + host bond setup in the lab guide.

---

## 5. Verify — and how to read it

**The Ethernet Segment and DF:**
```
leaf1> show evpn ethernet-segment
  ESI: 00:11:22:33:44:55:66:77:88:99
  Status: Resolved   Mode: all-active
  DF Election: ...  (one leaf is DF for BUM)
```
Both leaves should show the same ESI, `all-active`, and agree on who is DF.

**The bond is up on the host:**
```
host1$ cat /proc/net/bonding/bond0     → 802.3ad, both slaves up
```

**Aliasing — remote reachability via both leaves** (from the far side):
```
leaf(other)> show route ... <host1 MAC/ESI>   → next-hops via BOTH leaf1 and leaf2
```

**The payoff — redundancy test:** ping host1 continuously, then fail one uplink
(next section) — the ping keeps going.

---

## 6. Break & observe

**Fail one of host1's uplinks** (deactivate leaf1's `ae0` member):
```
leaf1# deactivate interfaces ge-0/0/2   ; commit
```
- **Predict:** does host1 stay reachable? Any packet loss?
- **Observe:** leaf1 withdraws its Type-1 per-ES; remote VTEPs instantly move all of
  host1's traffic to **leaf2**. A continuous ping to host1 shows little or no loss.
  This is the resilience the whole session is about.
- **Reverse:** `activate interfaces ge-0/0/2 ; commit` — load-balancing resumes.

**Break the ESI match** (change the ESI on only one leaf):
- **Observe:** the two ports are no longer seen as one segment — the host's bond or
  DF election misbehaves. Shows why the ESI must be **identical** on both leaves.

---

## 7. Lessons & interview

- **Same ESI + same LACP system-id on both leaves** = one Ethernet Segment / one
  host bond. This is the core of EVPN multihoming.
- **Type-4** elects the DF (BUM); **Type-1 per-ES** = fast failover; **Type-1
  per-EVI** = aliasing (load-balance to the host).
- EVPN multihoming needs **no peer-link** and isn't limited to pairs — its
  advantage over vPC/MC-LAG.

**⚠️ Validation status:** LACP bonds + ESI have several moving parts; this lab is
**pending live validation** — treat the config as a strong draft.

**Interview questions:**
1. Why does a multihomed segment need a Designated Forwarder, and which route type
   elects it?
2. What do Type-1 per-ES and Type-1 per-EVI routes each provide?
3. What two values must match on both leaves for EVPN all-active multihoming, and why?
4. How is EVPN multihoming better than MC-LAG/vPC?
5. A host's uplink to leaf1 fails. Trace what happens in the control plane that keeps
   it reachable in under a second.

---

**Next:** Session 7 — **eBGP designs** — an eBGP underlay and an eBGP-EVPN overlay,
the alternative to OSPF+iBGP that many large fabrics run.
