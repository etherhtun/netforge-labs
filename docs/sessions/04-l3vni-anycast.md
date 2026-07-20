# Session 4 — L3VNI & the Anycast Gateway

> **Goal:** let hosts in *different* subnets talk across the fabric. Session 3
> stretched one subnet (L2VNI, bridging). Now we add a second subnet and **route
> between them** — with a gateway that lives on *every* leaf (anycast) and a
> Layer-3 VNI that carries routed traffic between VTEPs. This is what turns a
> bridging fabric into a full routing fabric.

*Prerequisite: underlay (S1), overlay-RR (S2), and L2VNI (S3) understood.*

---

## 1. Mental model

- An **L2VNI** is a *room* stretched across buildings (Session 3).
- An **L3VNI** is the **hallway system** that connects different rooms so people in
  room 100 can reach people in room 200.
- The **anycast gateway** is a **reception desk with the same address and the same
  face on every single floor of every building.** Wherever you are, your nearest
  desk *is* the gateway — you never walk to another building to find the exit. If
  you move desks (VM mobility), the gateway is still right next to you.

That "same gateway everywhere" is the trick that makes routing in a stretched
fabric optimal instead of hair-pinning traffic to one central router.

---

## 2. Why before how

**Why do we need routing at all — isn't bridging enough?**
Bridging (L2VNI) only connects hosts in the *same* subnet. Real tenants have many
subnets (web / app / db tiers, different security zones). Traffic between them must
be **routed**. Without fabric routing, that traffic would hair-pin to a single
external router — a bottleneck and a failure point.

**Why an *anycast* gateway?**
In a stretched subnet, a host might live on any leaf. If the default gateway
existed on only one leaf, every host's routed traffic would first travel to *that*
leaf (hair-pinning), even to reach a neighbour one rack over. By putting the **same
gateway IP and MAC on every leaf**, each host's routed traffic is handled by its
*local* leaf — optimal paths, and the gateway follows a VM when it moves.

**Why an L3VNI (symmetric IRB) rather than putting every subnet on every leaf?**
You *could* configure every subnet's IRB on every leaf and route directly
(**asymmetric IRB**) — but then every leaf must know every subnet, which doesn't
scale. **Symmetric IRB** routes into a shared **L3VNI**: the ingress leaf routes
into the L3VNI, ships the packet across the fabric in that VNI, and the egress leaf
routes out to the destination subnet. Each leaf only needs the subnets it actually
serves plus the common L3VNI. It scales, and it's the modern default.

---

## 3. The mechanism (technical depth)

### IRB — Integrated Routing and Bridging
An **IRB interface** (`irb.100`) is the Layer-3 gateway for a VLAN/L2VNI — the
equivalent of an SVI. It's where a frame stops being bridged and starts being
routed. Each routed VLAN gets an IRB.

### The anycast gateway
Every leaf configures the **same** gateway address (and a shared virtual MAC) on
each IRB — e.g. `irb.100` = `10.100.10.1` on *all* leaves. A host ARPs for its
gateway and always gets its **local** leaf. Junos does this with a
`virtual-gateway-address` (a VRRP-like shared address) on the IRB. The result:
first-hop routing is always local.

### The L3VNI and the tenant VRF
Routed traffic for a tenant lives in a **routing-instance (VRF)** — say `TENANT` —
that owns the tenant's IRBs and is mapped to a dedicated **L3VNI** (e.g. 50000).
The VRF has its own RD and route-target. In Junos, Type-5 routing is turned on
inside the VRF:
```
set routing-instances TENANT protocols evpn ip-prefix-routes advertise direct-nexthop
set routing-instances TENANT protocols evpn ip-prefix-routes encapsulation vxlan
set routing-instances TENANT protocols evpn ip-prefix-routes vni 50000
```

### Type-5 (IP Prefix) routes
Where Type-2 advertises a **MAC** (bridging), **Type-5 advertises an IP prefix**
(routing) with no MAC attached. Each leaf advertises the subnets it serves as
Type-5 routes tagged with the L3VNI. A remote leaf imports them into the tenant
VRF and knows: *"to reach 10.100.20.0/24, route into L3VNI 50000 toward that
leaf's VTEP."*

### Symmetric IRB — the packet walk (host1 in VLAN 100 → host2 in VLAN 200)
1. host1 sends to its **local** anycast gateway on leaf1 (`irb.100`).
2. leaf1 **routes** the packet into the tenant VRF, encapsulates it in **VXLAN
   with the L3VNI (50000)**, dst = leaf2's VTEP (learned from leaf2's Type-5).
3. The underlay carries it (ECMP) to leaf2.
4. leaf2 decapsulates, sees L3VNI 50000 → tenant VRF, **routes** it out `irb.200`
   into VLAN 200, and delivers to host2.

Route → bridge across L3VNI → route. Symmetric on both ends. Neither leaf needed
the *other's* subnet as a local interface — only the shared L3VNI.

---

## 4. Build it

New lab: **[Lab 03 — anycast gateway + L3VNI](../labs/lab-03-l3vni.md)** (built on
the route-reflector fabric). It adds a second subnet and inter-subnet routing.

- VLAN 100 → L2VNI 10100, `10.100.10.0/24`, anycast GW `10.100.10.1`
- VLAN 200 → L2VNI 10200, `10.100.20.0/24`, anycast GW `10.100.20.1`
- Tenant VRF `TENANT` → **L3VNI 50000**
- host1 `10.100.10.10` (leaf1, VLAN 100) ↔ host2 `10.100.20.10` (leaf2, VLAN 200)

**Config, explained — the anycast IRB + L3VNI (per leaf):**
```
# IRBs — the anycast gateways (same virtual address on every leaf)
set interfaces irb unit 100 family inet address 10.100.10.2/24 virtual-gateway-address 10.100.10.1
set interfaces irb unit 200 family inet address 10.100.20.2/24 virtual-gateway-address 10.100.20.1

# VLANs get an L3 interface (the IRB) in addition to their L2VNI
set vlans v100 l3-interface irb.100
set vlans v200 vlan-id 200
set vlans v200 l3-interface irb.200
set vlans v200 vxlan vni 10200

# Tenant VRF with the L3VNI (Type-5 symmetric IRB)
set routing-instances TENANT instance-type vrf
set routing-instances TENANT interface irb.100
set routing-instances TENANT interface irb.200
set routing-instances TENANT route-distinguisher 10.0.0.21:100
set routing-instances TENANT vrf-target target:65000:5000
set routing-instances TENANT protocols evpn ip-prefix-routes advertise direct-nexthop
set routing-instances TENANT protocols evpn ip-prefix-routes encapsulation vxlan
set routing-instances TENANT protocols evpn ip-prefix-routes vni 50000
```
> The `.2` unique address differs per leaf; the `virtual-gateway-address .1` is the
> **shared anycast gateway** hosts point at. See the lab guide for the full per-node
> config.

---

## 5. Verify — and how to read it

### Type-5 routes carry the subnets
```
leaf1> show route table TENANT.evpn.0
5:10.0.0.22:100::0::10.100.20.0::24/248   ← leaf2 advertising 10.100.20.0/24 (Type-5)
```
The leading `5:` = Type-5 (IP Prefix), and it carries a **subnet**, not a MAC. This
is how leaf1 learns to reach VLAN 200's subnet via leaf2.

### The tenant VRF has the remote subnet
```
leaf1> show route table TENANT.inet.0 10.100.20.0/24
   → via the L3VNI toward leaf2's VTEP
```

### The gateway is local (anycast)
```
host1$ ip route         → default via 10.100.10.1   (its local leaf1 answers ARP)
```

### The payoff — inter-subnet ping across the fabric
```
host1$ ping -c3 10.100.20.10      → host in a DIFFERENT subnet, on a DIFFERENT leaf
```
`ttl` decrements (it was **routed**, not bridged) — the sign that the L3VNI did its
job.

---

## 6. Break & observe

**Remove the L3VNI from one leaf's VRF:**
```
leaf2# delete routing-instances TENANT protocols evpn ip-prefix-routes vni 50000  ; commit
```
- **Predict:** can host1 still reach host2?
- **Observe:** leaf2 stops advertising/importing Type-5 for the L3VNI — inter-subnet
  routing breaks while intra-subnet (L2VNI) still works. Restore it.

**Break the anycast gateway (change one leaf's virtual-gateway-address):**
- **Observe:** hosts on that leaf lose optimal first-hop routing / gateway
  reachability. Shows why the gateway address must be identical everywhere.

---

## 7. Lessons & interview

**Design notes:**
- **Anycast gateway** = same IP+MAC on every leaf → local-first routing + gateway
  follows VM mobility.
- **Symmetric IRB** (route-bridge-route via a shared L3VNI) scales better than
  asymmetric (every subnet on every leaf) and is the modern default.

**⚠️ Validation status:** this lab's config is written to the standard Junos
symmetric-IRB pattern but is **pending live validation on vJunos** — treat the exact
syntax as a strong draft until confirmed (the lab guide flags the same).

**Interview questions:**
1. What's the difference between an L2VNI and an L3VNI?
2. What problem does an anycast gateway solve in a stretched subnet?
3. Symmetric vs asymmetric IRB — how do they differ and which scales better?
4. What does a Type-5 route carry that a Type-2 does not?
5. Trace a packet from a host in VLAN 100 to a host in VLAN 200 on another leaf —
   where is it bridged, where routed, and which VNI carries it across the fabric?

---

**Next:** Session 5 — **Multi-tenancy** — multiple VRFs on the same fabric, kept
isolated by route-targets, and controlled route leaking between them.
