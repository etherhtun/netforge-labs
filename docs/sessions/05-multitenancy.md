# Session 5 — Multi-Tenancy (VRFs, Isolation & Route Leaking)

> **Goal:** run **many independent tenants** on the same physical fabric, fully
> isolated from each other — then selectively let them share, on purpose. This is
> what makes a fabric a *cloud* fabric: one set of hardware, many customers, each
> in their own sealed world, with controlled doors between them when you want.

*Prerequisite: L3VNI / anycast gateway (Session 4).*

---

## 1. Mental model

Think of the fabric as an **office building** and each tenant as a **separate
company** renting floors. By default:

- Each company's floors are **key-card locked** — company A can't wander onto
  company B's floors. They can even both number their floors "Floor 1" (overlapping
  IPs) without confusion, because the key-card system keeps them separate.
- Sometimes you *want* a **shared floor** (a common cafeteria, or shared services
  like DNS) that specific companies are allowed onto. You grant that access
  explicitly — a controlled door between otherwise-sealed worlds. That's **route
  leaking**.

The key-card system is the **route-target**. It decides who can see whose routes.

---

## 2. Why before how

**Why isolate tenants?**
Security and blast-radius: tenant A must not reach tenant B's workloads. And
**overlapping IPs** — two tenants may both use `10.0.0.0/8` internally; the fabric
must keep them apart so those addresses don't collide.

**Why not just ACLs/firewalls between them?**
Filters are brittle and don't solve overlapping IPs. VRF-based isolation is
*structural* — the routes literally don't exist in the other tenant's table, so
there's nothing to filter. Cleaner and scales.

**Why allow leaking at all?**
Real deployments need **shared services** (DNS, monitoring, backup) reachable by
many tenants, or specific inter-tenant flows. Rather than merging tenants, you
**leak** just the needed routes — controlled, auditable sharing.

---

## 3. The mechanism (technical depth)

### One VRF per tenant
Each tenant gets its own **routing-instance (VRF)** with its own **L3VNI**, **route
distinguisher**, and **route-target**. Tenant-A's subnets live only in Tenant-A's
VRF; Tenant-B's in Tenant-B's. Separate tables → structural isolation. Because the
RD makes routes globally unique, **overlapping tenant IPs are fine** — `10.1.1.0/24`
in Tenant-A and the same prefix in Tenant-B are different routes in BGP.

### The route-target *is* the isolation boundary
Recall from Session 2: a VTEP **imports** routes whose RT it's configured for, and
**exports** its routes tagged with its RT. Give each tenant a **distinct RT**:

- Tenant-A: `vrf-target target:65000:5000`
- Tenant-B: `vrf-target target:65000:5001`

A leaf's Tenant-A VRF imports only `:5000` routes; it never even *sees* Tenant-B's
`:5001` routes. Isolation isn't a filter you add — it's the *absence* of a shared
RT.

### Route leaking — opening a controlled door
To let two tenants share, you make one VRF **import the other's RT** (or export a
subset to a shared RT). For example, to let Tenant-A reach Tenant-B:

```
set routing-instances TENANT-A vrf-import LEAK-FROM-B
set policy-options policy-statement LEAK-FROM-B term b from community RT-B
set policy-options policy-statement LEAK-FROM-B term b then accept
set policy-options community RT-B members target:65000:5001
```
Now Tenant-A's table also imports Tenant-B's routes — a one-way (or, if mirrored,
two-way) door. You leak **only** what you intend, and it's visible in config for
audit. (Many designs instead use a dedicated **shared-services VRF** that both
tenants leak with.)

### What stays shared vs separate
- **Shared:** the underlay, the BGP-EVPN overlay sessions, the physical VTEPs.
- **Separate:** each tenant's L3VNI, VRF table, and (optionally) L2VNIs.

One fabric, many sealed tenants — the essence of multi-tenancy.

---

## 4. Build it

New lab: **[Lab 04 — multi-tenancy](../labs/lab-04-multitenancy.md)** (built on the
L3VNI fabric). Two tenants, prove isolation, then leak.

- **Tenant-A:** VRF `TENANT-A`, VLAN 100 `10.100.10.0/24`, L3VNI 50000, RT `:5000`
- **Tenant-B:** VRF `TENANT-B`, VLAN 300 `10.100.30.0/24`, L3VNI 50001, RT `:5001`
- host1 `10.100.10.10` (Tenant-A) · host2 `10.100.30.10` (Tenant-B)

**Config sketch — a second tenant VRF (leaf, per node):**
```
set routing-instances TENANT-B instance-type vrf
set routing-instances TENANT-B interface irb.300
set routing-instances TENANT-B route-distinguisher 10.0.0.21:200
set routing-instances TENANT-B vrf-target target:65000:5001
set routing-instances TENANT-B protocols evpn ip-prefix-routes advertise direct-nexthop
set routing-instances TENANT-B protocols evpn ip-prefix-routes encapsulation vxlan
set routing-instances TENANT-B protocols evpn ip-prefix-routes vni 50001
```
Same shape as Tenant-A, **different L3VNI (50001) and RT (:5001)** — that
difference is the entire isolation. Full per-node config in the lab guide.

---

## 5. Verify — and how to read it

**Isolation (the default):**
```
host1$ ping 10.100.30.10        → FAILS (Tenant-A can't see Tenant-B)
```
```
leaf1> show route table TENANT-A.inet.0
   → only Tenant-A subnets; NO 10.100.30.0/24
```
The remote tenant's subnet is simply **not in the table** — nothing to filter.

**After leaking:**
```
host1$ ping 10.100.30.10        → SUCCEEDS
leaf1> show route table TENANT-A.inet.0
   → now includes 10.100.30.0/24 (leaked from Tenant-B via RT import)
```

**Overlapping IPs stay distinct** — the same prefix in two VRFs shows as two
separate routes, disambiguated by RD.

---

## 6. Break & observe

**Accidentally share an RT:** set Tenant-B's `vrf-target` to `:5000` (same as
Tenant-A).
- **Predict:** what happens to isolation?
- **Observe:** the tenants now import each other's routes automatically — isolation
  collapses. This shows the RT *is* the boundary. Restore `:5001`.

**Leak one-way:** import Tenant-B's RT into Tenant-A but not vice-versa.
- **Observe:** A can reach B's routes but B has no return route — asymmetric
  reachability, so traffic fails one way. Teaches that leaking must be mutual for
  two-way flows.

---

## 7. Lessons & interview

- **The route-target is the tenant boundary.** Distinct RT = isolation; shared/
  imported RT = leaking. No ACL required for the base isolation.
- **VRFs enable overlapping IPs** — RD makes routes globally unique.
- Prefer a **shared-services VRF** pattern over ad-hoc pairwise leaking when many
  tenants need common services.

**⚠️ Validation status:** lab config is the standard Junos pattern but **pending
live validation** (builds on the still-draft L3VNI lab).

**Interview questions:**
1. How do VRFs provide tenant isolation without any ACL, and how do they allow
   overlapping IPs?
2. What single attribute controls whether two tenants can see each other's routes?
3. How would you give many tenants access to a shared DNS server without merging
   them?
4. You leaked Tenant-B's routes into Tenant-A but ping still fails. What did you
   forget?

---

**Next:** Session 6 — **ESI multihoming** — dual-home a host to two leaves,
all-active, with Type-1/Type-4 routes and Designated-Forwarder election.
