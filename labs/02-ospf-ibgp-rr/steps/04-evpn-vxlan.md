# Step 4 — EVPN + VXLAN glue

## What this step does
Now we turn on the actual overlay data plane on the **leaves** (the VTEPs). Three
pieces bolt together:

1. **`protocols evpn`** — turn on EVPN, choose VXLAN encapsulation, and say which
   VNIs to handle.
2. **`switch-options`** — the VTEP settings: source the tunnel from `lo0.0`, and
   set the Route Distinguisher (RD) and Route Target (RT).
3. **A VLAN → VNI mapping** — bridge VLAN 100 onto VXLAN VNI 10100.

> **RD vs RT (quick reminder):** RD makes each leaf's routes *unique* (different
> per leaf). RT controls *membership* — same RT = same virtual network (shared).
> See [Study lesson 4](https://etherhtun.github.io/vxlan-evpn-juniper/study/04-evpn-controlplane/).

Only the **leaves** get this — the spines are route-reflectors, **not** VTEPs, so
they have no `switch-options` or `vlans`.

## Config — leaves only (note the RD differs per leaf)
**leaf1:**
```
set protocols evpn encapsulation vxlan
set protocols evpn extended-vni-list all
set switch-options vtep-source-interface lo0.0
set switch-options route-distinguisher 10.0.0.21:1
set switch-options vrf-target target:65000:1
set vlans v100 vlan-id 100
set vlans v100 vxlan vni 10100
```
**leaf2** — same, but `route-distinguisher 10.0.0.22:1`.

Or: `./scripts/apply.sh 02-ospf-ibgp-rr 04`

## ⚠️ Important Junos behavior — no routes appear *yet*, and that's correct
After you commit this, check `show route table bgp.evpn.0` on a leaf — it's
**still empty**, and `show bgp summary` shows the EVPN instance
(`default-switch.evpn.0`) with 0 routes.

**This is not a bug.** Junos only advertises a VNI (the Type-3 route) once that
VLAN has an **operationally-up member interface**. Right now VLAN 100 has no
ports in it, so there's nothing to flood to, so nothing is advertised. It all
lights up in **Step 5**, when we add the host-facing access port.

(This differs from Cisco, which advertises as soon as the VNI is defined — a
classic gotcha worth remembering.)

## Verify (what to expect *now*)
On **leaf1**:
```
show configuration vlans          → v100 with vxlan vni 10100
show configuration switch-options → vtep-source-interface lo0.0, RD, vrf-target
show bgp summary                  → default-switch.evpn.0 listed, 0 routes (correct)
```

## Checkpoint
✅ Config committed on both leaves and `default-switch.evpn.0` appears in
`show bgp summary` → go to Step 5, where it all comes alive.

→ Next: [Step 5 — Services & verify](05-services-verify.md)
