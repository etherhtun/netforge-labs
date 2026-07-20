# Lab 04 — Multi-tenancy (two tenants, isolation + route leaking)

> **Complete, self-contained guide.** Two tenants share one fabric, fully isolated
> — then you leak routes between them on purpose. Pairs with
> **[Session 5](../sessions/05-multitenancy.md)**.
>
> ⚠️ **DRAFT — pending live validation** (builds on the L3VNI pattern; not yet run
> on vJunos).

---

## What you'll build

| Tenant | VRF | VLAN / L2VNI | Subnet | L3VNI | RT |
|--------|-----|--------------|--------|-------|----|
| A | `TENANT-A` | 100 / 10100 | `10.100.10.0/24` | 50000 | `target:65000:5000` |
| B | `TENANT-B` | 300 / 10300 | `10.100.30.0/24` | 50001 | `target:65000:5001` |

- host1 `10.100.10.10` (Tenant-A, leaf1) · host2 `10.100.30.10` (Tenant-B, leaf2)
- Overlay = spine route reflectors. Fabric: `clab-evpn-mt-*`. Login `admin`/`admin@123`.

**The whole point:** distinct route-targets (`:5000` vs `:5001`) = the tenants
can't see each other. Same fabric, sealed worlds.

## Before you start
Only one lab at a time (RAM):
```bash
docker ps --format '{{.Names}}' | grep '^clab-' || echo "clean"
sudo docker rm -f $(docker ps -aq --filter name=clab-)   # if needed
```

## Run it
```bash
./scripts/deploy.sh 04-multitenancy && ./scripts/apply.sh 04-multitenancy all
```
Host setup:
```bash
docker exec clab-evpn-mt-host1 sh -c "ip addr add 10.100.10.10/24 dev eth1; ip link set eth1 up; ip route replace default via 10.100.10.1"
docker exec clab-evpn-mt-host2 sh -c "ip addr add 10.100.30.10/24 dev eth1; ip link set eth1 up; ip route replace default via 10.100.30.1"
```

---

## The build

Steps 1–3 (fabric, OSPF, RR overlay) = same as [Lab 02](lab-02-rr.md). **Step 4**
defines two tenant VRFs — same shape, **different L3VNI and RT** (that difference
*is* the isolation). **leaf1** (leaf2 mirrors, `.3` IRBs, RD `10.0.0.22`):

```
set switch-options vtep-source-interface lo0.0
set switch-options route-distinguisher 10.0.0.21:1
set switch-options vrf-target target:65000:1
set protocols evpn encapsulation vxlan
set protocols evpn extended-vni-list all
set vlans v100 vlan-id 100
set vlans v100 l3-interface irb.100
set vlans v100 vxlan vni 10100
set vlans v300 vlan-id 300
set vlans v300 l3-interface irb.300
set vlans v300 vxlan vni 10300
set interfaces irb unit 100 family inet address 10.100.10.2/24 virtual-gateway-address 10.100.10.1
set interfaces irb unit 300 family inet address 10.100.30.2/24 virtual-gateway-address 10.100.30.1
set routing-instances TENANT-A instance-type vrf
set routing-instances TENANT-A interface irb.100
set routing-instances TENANT-A route-distinguisher 10.0.0.21:100
set routing-instances TENANT-A vrf-target target:65000:5000
set routing-instances TENANT-A protocols evpn ip-prefix-routes advertise direct-nexthop
set routing-instances TENANT-A protocols evpn ip-prefix-routes encapsulation vxlan
set routing-instances TENANT-A protocols evpn ip-prefix-routes vni 50000
set routing-instances TENANT-B instance-type vrf
set routing-instances TENANT-B interface irb.300
set routing-instances TENANT-B route-distinguisher 10.0.0.21:200
set routing-instances TENANT-B vrf-target target:65000:5001
set routing-instances TENANT-B protocols evpn ip-prefix-routes advertise direct-nexthop
set routing-instances TENANT-B protocols evpn ip-prefix-routes encapsulation vxlan
set routing-instances TENANT-B protocols evpn ip-prefix-routes vni 50001
```
Step 5 access ports: leaf1 `ge-0/0/2` → `v100`; leaf2 `ge-0/0/2` → `v300`.

---

## Verify

**Isolation (default) — the cross-tenant ping must FAIL:**
```bash
docker exec clab-evpn-mt-host1 ping -c3 10.100.30.10        # → 100% loss (isolated) ✅ correct
```
```
leaf1> show route table TENANT-A.inet.0     → only 10.100.10.0/24; NO 10.100.30.0/24
```
The other tenant's subnet isn't in the table — nothing to filter, structurally isolated.

## Now leak Tenant-B → Tenant-A (open a controlled door)
On **both leaves**, make Tenant-A import Tenant-B's RT (and vice-versa for two-way):
```
set policy-options community RT-B members target:65000:5001
set policy-options community RT-A members target:65000:5000
set policy-options policy-statement LEAK-A-B term 1 from community [ RT-A RT-B ]
set policy-options policy-statement LEAK-A-B term 1 then accept
set routing-instances TENANT-A vrf-import LEAK-A-B
set routing-instances TENANT-B vrf-import LEAK-A-B
```
Re-test — now it should SUCCEED:
```bash
docker exec clab-evpn-mt-host1 ping -c3 10.100.30.10        # → 0% loss (leaked) 🎉
leaf1> show route table TENANT-A.inet.0     → now includes 10.100.30.0/24
```

## Break-it
1. **Share an RT by mistake** (set Tenant-B `vrf-target` to `:5000`) → isolation
   collapses; both tenants auto-import each other. Shows the RT *is* the boundary.
2. **Leak one-way only** (import B into A, not A into B) → A→B has no return route;
   ping fails one direction. Leaking must be mutual for two-way flows.

## Validation notes (draft)
Likely spots to check live: whether `vrf-import` fully overrides the default
`vrf-target` import (may need `vrf-target` + explicit import policy together), and
that both L3VNIs appear in `show evpn instance`. Paste `show route table
TENANT-A.inet.0` (before and after leak) and any commit errors and we'll finalize.
