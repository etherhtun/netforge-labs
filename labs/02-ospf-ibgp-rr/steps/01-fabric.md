# Step 1 — Fabric: interfaces & loopbacks

> **New here?** Read the [Study track](https://etherhtun.github.io/vxlan-evpn-juniper/study/)
> first for the theory. This lab builds a **production** VXLAN-EVPN fabric with
> spine route-reflectors. Do the steps in order; each ends with a check you must
> pass before moving on.

## What this step does
Every switch needs two kinds of addresses before any protocol can run:

1. **Fabric-link IPs** — the point-to-point `/31` addresses on the cables between
   spines and leaves. These let directly-connected neighbours talk.
2. **A loopback (`lo0.0`)** — a `/32` address that represents the *device itself*.
   It never goes down as long as the box is up. On a leaf this loopback is the
   most important address in the whole design: it's the router-id, the BGP
   peering address, **and** the source of every VXLAN tunnel.

We assign these on all four switches. (Addresses come from the
[IP plan](https://github.com/etherhtun/vxlan-evpn-juniper/blob/main/common/ipplan.md).)

## Interface naming
vJunos-switch presents ports as **`ge-0/0/N`**. The containerlab cabling maps
with a +1 offset: clab `eth1` → `ge-0/0/0`, `eth2` → `ge-0/0/1`, `eth3` →
`ge-0/0/2`. (Ignore the `ge-0/0/N.16386` sub-units — those are internal.)

## Config
Enter config mode with `configure`, paste your node's block, then `commit`.

**spine1:**
```
set interfaces ge-0/0/0 unit 0 family inet address 10.10.1.0/31
set interfaces ge-0/0/1 unit 0 family inet address 10.10.2.0/31
set interfaces lo0 unit 0 family inet address 10.0.0.11/32
set routing-options router-id 10.0.0.11
```
**spine2:**
```
set interfaces ge-0/0/0 unit 0 family inet address 10.10.3.0/31
set interfaces ge-0/0/1 unit 0 family inet address 10.10.4.0/31
set interfaces lo0 unit 0 family inet address 10.0.0.12/32
set routing-options router-id 10.0.0.12
```
**leaf1:**
```
set interfaces ge-0/0/0 unit 0 family inet address 10.10.1.1/31
set interfaces ge-0/0/1 unit 0 family inet address 10.10.3.1/31
set interfaces lo0 unit 0 family inet address 10.0.0.21/32
set routing-options router-id 10.0.0.21
```
**leaf2:**
```
set interfaces ge-0/0/0 unit 0 family inet address 10.10.2.1/31
set interfaces ge-0/0/1 unit 0 family inet address 10.10.4.1/31
set interfaces lo0 unit 0 family inet address 10.0.0.22/32
set routing-options router-id 10.0.0.22
```

Or apply it all with one command: `./scripts/apply.sh 02-ospf-ibgp-rr 01`

## Verify
On **leaf1**:
```
show interfaces terse | match "ge-|lo0"     → links show up/up, addresses present
ping 10.10.1.0 count 3                        → leaf1 → spine1 across the /31
```
The ping works because the two ends are **directly connected** — no routing
needed yet. (Loopback-to-loopback across the fabric won't work until Step 2.)

## Checkpoint
✅ All fabric links `up/up`, every loopback present, and each `/31` pings its
neighbour → go to Step 2.

→ Next: [Step 2 — Underlay OSPF](02-underlay-ospf.md)
