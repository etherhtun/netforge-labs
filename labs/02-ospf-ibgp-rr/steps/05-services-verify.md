# Step 5 — Services: attach hosts & prove it end-to-end

This is the finish line: put the host-facing ports into VLAN 100, give the two
hosts IPs, and watch a ping cross the VXLAN fabric.

## 5a — Access ports (on each leaf)
An **access port** is a plain host-facing switch port in one VLAN. Configure
`ge-0/0/2` (which connects to the host) into VLAN 100:

**leaf1 and leaf2 (same):**
```
set interfaces ge-0/0/2 unit 0 family ethernet-switching interface-mode access
set interfaces ge-0/0/2 unit 0 family ethernet-switching vlan members v100
```
`configure` → paste → `commit`. Or: `./scripts/apply.sh 02-ospf-ibgp-rr 05`

**The moment this commits, VLAN 100 has an up member** — so each leaf now
advertises its **Type-3 (IMET)** route, the VTEPs discover each other, and the
VXLAN tunnel forms. Confirm on **leaf1**:
```
show route table bgp.evpn.0
```
You should see two Type-3 routes (leading `3:`), one per leaf. And the tunnel:
```
show ethernet-switching vxlan-tunnel-end-point remote
   → a remote VTEP (RVTEP) for the other leaf, carrying VNID 10100
```

## 5b — Give the hosts IPs (on the containerlab host shell, NOT Junos)
Exit to the `rwh@clab-lab` shell and run:
```
docker exec clab-vxlan-evpn-jnpr-host1 sh -c "ip addr add 10.100.10.10/24 dev eth1; ip link set eth1 up"
docker exec clab-vxlan-evpn-jnpr-host2 sh -c "ip addr add 10.100.10.11/24 dev eth1; ip link set eth1 up"
docker exec clab-vxlan-evpn-jnpr-host1 ping -c3 10.100.10.11
```
Those three packets go **host1 → leaf1 → (VXLAN across the fabric) → leaf2 →
host2**. `0% packet loss` means the whole thing works. 🎉

## Verify Type-2 (MAC learning) on leaf1
```
show evpn database
   → host2's MAC learned via the remote VTEP (its loopback), host1 learned locally

show ethernet-switching table
   → host2's MAC flagged DR (Dynamic Remote) via vtep.xxxxx — it lives on a tunnel,
     not a physical wire
```

## ⭐ Prove the route-reflectors stay out of the data path
This is what makes it *production RR*. On **leaf1**:
```
show route table bgp.evpn.0 extensive | match "Protocol next hop"
   → next hop is 10.0.0.22 (leaf2), NOT a spine
```
Even though the route was *reflected* by a spine, the next hop is the far leaf —
so the VXLAN tunnel is leaf-to-leaf and the spine never touches a data packet.

## Checkpoint
✅ Cross-fabric ping works, Type-2 MACs learned, and the data-plane next-hop is
a leaf (not a spine) → **lab complete.** Run the [verify checklist](../verify.md),
then try the [break-it exercises](../break-it.md).

→ Back to the [lab overview](../README.md)
