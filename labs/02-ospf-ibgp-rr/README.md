# Lab 02 — OSPF underlay + iBGP-EVPN with **spine route-reflectors**

The **production-grade** overlay. Same 2×2 fabric as lab 01, but the overlay
scales: leaves peer only to the spines, and the spines reflect EVPN routes
between them.

> **Why this exists:** full-mesh iBGP (lab 01) needs N×(N-1)/2 sessions — fine
> for 2 leaves, unmanageable at scale. Real fabrics use **spine-as-route-reflector**
> so each leaf has just 2 overlay sessions (to the 2 spines), forever.

## Design

| Layer    | Choice |
|----------|--------|
| Underlay | OSPF (single area 0) — *identical to lab 01* |
| Overlay  | iBGP-EVPN, AS 65000, **spines = route reflectors, leaves = clients** |
| Spines   | run BGP-EVPN as **RR** (`cluster`) — control-plane only, **NOT VTEPs** |
| Services | one L2VNI (VLAN 100 → VNI 10100) — *identical to lab 01* |

## ⭐ The key idea: spine is control-plane only

The spine reflects EVPN routes but **keeps the next-hop unchanged** (the
originating leaf's loopback). So:

```mermaid
graph TB
    S1["spine1 · RR<br/>reflects routes"]
    S2["spine2 · RR<br/>reflects routes"]
    L1["leaf1 · VTEP<br/>10.0.0.21"]
    L2["leaf2 · VTEP<br/>10.0.0.22"]
    L1 ---|iBGP-EVPN| S1
    L1 ---|iBGP-EVPN| S2
    L2 ---|iBGP-EVPN| S1
    L2 ---|iBGP-EVPN| S2
    L1 -. "VXLAN tunnel (data) — still leaf-to-leaf" .- L2

    classDef spine fill:#e3f2fd,stroke:#1565c0,color:#0d47a1;
    classDef leaf  fill:#e8f5e9,stroke:#2e7d32,color:#1b5e20;
    class S1,S2 spine;
    class L1,L2 leaf;
```

The **control plane** goes leaf → spine → leaf (reflected). The **data plane**
(the VXLAN tunnel) is still **leaf → leaf directly**. The spine never
encapsulates a data packet — it's not a VTEP.

## The build — follow the steps in order

Each step has the concept, the exact config, and a verify command you must pass
before moving on. This lab is self-contained — you don't need lab 01 open.

| Step | File | Verifies before you continue |
|------|------|------------------------------|
| 1 | [steps/01-fabric.md](steps/01-fabric.md) | interfaces up, loopbacks present, `/31` pings |
| 2 | [steps/02-underlay-ospf.md](steps/02-underlay-ospf.md) | leaf-to-leaf loopback ping |
| **3** | **[steps/03-overlay-rr.md](steps/03-overlay-rr.md)** | leaves peer to **both spines** (the RR part) |
| 4 | [steps/04-evpn-vxlan.md](steps/04-evpn-vxlan.md) | EVPN instance up (routes come in Step 5) |
| 5 | [steps/05-services-verify.md](steps/05-services-verify.md) | host ↔ host ping; spine stays out of data path |

Then: [verify.md](verify.md) (full checklist) and [break-it.md](break-it.md)
(deliberate failures — #2 teaches *why* RR exists).

> Steps 1, 2, 4, 5 are the same commands as lab 01 (the fabric, underlay, and
> VXLAN don't change). **Step 3 is where the production RR design lives.**

## Run it

```bash
./scripts/deploy.sh 02-ospf-ibgp-rr       # boot the fabric
./scripts/apply.sh  02-ospf-ibgp-rr all   # build it (RR overlay and all)
# host setup + ping (apply.sh prints the commands)
./scripts/reset.sh  02-ospf-ibgp-rr       # wipe & redo
```

Or per step: `./scripts/apply.sh 02-ospf-ibgp-rr 03` applies just the RR overlay.

## Status

🏗️ Built from the validated lab-01 pattern; **overlay pending live validation**
(see the one open check in [steps/03-overlay-rr.md](steps/03-overlay-rr.md) — does
the Junos spine retain EVPN routes as a non-VTEP RR).
