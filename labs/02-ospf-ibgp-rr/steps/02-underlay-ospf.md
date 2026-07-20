# Step 2 — Underlay: OSPF

## What this step does
The **underlay** is the plain IP network underneath everything. Its one and only
job: **make every loopback reachable from every other loopback**, over multiple
equal paths (ECMP). Nothing about VXLAN or EVPN yet — just IP reachability, so
the VXLAN tunnels we build later have somewhere to land.

We use **OSPF** (a simple link-state routing protocol). Every fabric link joins
OSPF area 0 as a point-to-point link, and each loopback is advertised as
*passive* (announced into OSPF, but OSPF doesn't try to form a neighbour over the
loopback itself).

## Why "passive" on the loopback?
A passive interface is **advertised** but doesn't send/receive OSPF hellos.
You want the loopback's `/32` reachable everywhere (so advertise it), but there's
no neighbour on a loopback to talk to — so keep it passive.

## Config — identical on all four switches
```
set protocols ospf area 0 interface lo0.0 passive
set protocols ospf area 0 interface ge-0/0/0.0 interface-type p2p
set protocols ospf area 0 interface ge-0/0/1.0 interface-type p2p
```
`configure` → paste → `commit` on spine1, spine2, leaf1, leaf2.

Or: `./scripts/apply.sh 02-ospf-ibgp-rr 02`

> **Tip:** after commit, give OSPF ~30 seconds to form neighbours. If
> `show ospf neighbor` says *"OSPF instance is not running"*, you likely ran it
> before the commit settled — just re-check.

## Verify — this is the gate
On **leaf1**:
```
show ospf neighbor              → both spines (10.0.0.11, 10.0.0.12) in state Full
show route 10.0.0.22            → a route to leaf2's loopback, via a spine
ping 10.0.0.22 source 10.0.0.21 → MUST succeed
```
That last ping — leaf1's loopback reaching leaf2's loopback *through a spine* —
is the foundation everything above stands on. The reply comes back with `ttl=63`
(one less than 64), which tells you it took **one hop through a spine**, proving
it really crossed the fabric.

## Checkpoint
✅ Loopback-to-loopback ping works between the leaves → go to Step 3.
**If it fails, stop and fix the underlay — nothing above will work without it.**

→ Next: [Step 3 — Overlay with route-reflectors](03-overlay-rr.md)
