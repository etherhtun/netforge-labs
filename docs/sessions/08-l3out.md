# Session 8 — External Connectivity (L3 Out)

> **Goal:** get tenant traffic **in and out of the fabric** — to the WAN, the
> internet, or a firewall. Everything so far has been *inside* the fabric; a real
> data center must also talk to the outside world, per-tenant and controlled.

*Prerequisite: L3VNI / tenant VRFs (Sessions 4–5).*

---

## 1. Mental model

The fabric is a **gated community** — beautifully connected inside, but sealed. An
**L3 Out is the gate to the outside world**: a designated exit (a **border leaf**)
where the community's private roads meet the public highway. Each tenant gets its
*own* gate into *its* slice of the outside (its VRF), so tenant A's exit doesn't
leak into tenant B's.

---

## 2. Why before how

**Why do we need this?**
Workloads reach the internet, on-prem networks, other data centers, or pass through
a firewall. The fabric's Type-2/Type-5 routes only describe what's *inside*; to
reach anything external you need a controlled hand-off to an external router.

**Why on a *border leaf* rather than everywhere?**
Concentrating external peering on one or two **border leaves** keeps the edge
policy (filtering, NAT hand-off, route control) in one place, and keeps spines pure
transport. Other leaves just send external-bound traffic toward the border via a
default/summary route.

**Why per-tenant?**
Tenant isolation must extend to the edge — tenant A's internet path and routes must
stay separate from tenant B's. So the external peering lives **inside each tenant's
VRF**, not the global table.

---

## 3. The mechanism (technical depth)

### The border leaf and the external peering
A **border leaf** has a link (or sub-interfaces) to an **external router** (WAN
edge / firewall). Inside the **tenant VRF**, the border leaf runs **eBGP (or static
routes)** to that external router:
- **Learns** external prefixes (e.g. a default route, or specific WAN prefixes)
  from the external router.
- **Advertises** the tenant's internal subnets *out* to the external router so
  return traffic can come back.

### Injecting external routes into the fabric
Once the border leaf has external routes in the tenant VRF, EVPN **Type-5** carries
them to every other leaf in that tenant — just like any internal subnet. Commonly
you originate a **default route (0.0.0.0/0)** as a Type-5 into the tenant: now every
leaf knows "anything I don't recognise → send it to the border leaf," and the
border leaf forwards it out the L3 Out.

### The traffic path
1. host on leaf2 sends to an internet IP → no specific route → follows the tenant
   **default route** (Type-5 from the border leaf) across the fabric (L3VNI).
2. The **border leaf** receives it, routes it in the tenant VRF out the external
   link to the WAN router.
3. Return traffic comes back to the border leaf (which advertised the tenant subnet
   externally) → into the fabric → back to the host.

### Keeping it isolated & safe
- The external peering is **per-VRF**, so tenants stay separate to the edge.
- You control exactly what's advertised out (only the tenant's own subnets) and
  what's accepted in (a default, or a filtered set) with **BGP policy** — the edge
  is where you enforce it.

---

## 4. Build it

*(Lab 07 — L3 Out — needs an **extra node**: an external router, e.g. FRR or cEOS
in containerlab, attached to a border leaf. Built after the core labs are
validated. The border-leaf design is shown here.)*

**Config sketch — border leaf, external eBGP inside the tenant VRF:**
```
# Link to the external router (in the tenant VRF)
set interfaces ge-0/0/4 unit 0 family inet address 192.0.2.1/30
set routing-instances TENANT interface ge-0/0/4.0
# eBGP to the external router, inside the VRF
set routing-instances TENANT protocols bgp group L3OUT type external
set routing-instances TENANT protocols bgp group L3OUT peer-as 65500
set routing-instances TENANT protocols bgp group L3OUT neighbor 192.0.2.2
# Originate a default route into the tenant so all leaves exit via here
set routing-instances TENANT protocols evpn ip-prefix-routes advertise direct-nexthop
set policy-options policy-statement DEFAULT-OUT term 1 from route-filter 0.0.0.0/0 exact
set policy-options policy-statement DEFAULT-OUT term 1 then accept
```
The external router (FRR/cEOS) peers back and advertises a default (or WAN
prefixes). Non-border leaves need no L3Out config — they just follow the default.

---

## 5. Verify — and how to read it

**Border leaf learned external routes:**
```
border-leaf> show route table TENANT.inet.0 0.0.0.0/0
   → default via the external router (192.0.2.2)
```
**Other leaves received the default via Type-5:**
```
leaf2> show route table TENANT.inet.0 0.0.0.0/0
   → default, next-hop = the border leaf's VTEP (L3VNI)
```
**End-to-end:** a tenant host pings an external address (behind the WAN router) →
success; the path exits via the border leaf.

---

## 6. Break & observe

- **Withdraw the external default** (shut the L3Out eBGP session) → tenant hosts
  lose internet reachability but keep intra-fabric connectivity. Shows the fabric
  and the edge are decoupled.
- **Advertise the wrong tenant's subnet externally** → return traffic lands in the
  wrong VRF. Shows why the edge policy must be per-tenant and precise.

---

## 7. Lessons & interview

- External connectivity lives on a **border leaf, inside the tenant VRF**, via eBGP
  (or static) to a WAN/firewall router. **Type-5 (often a default route)** carries
  it to the rest of the fabric.
- Concentrating the edge keeps policy in one place and spines pure.

**Interview questions:**
1. Why is external peering done inside a tenant VRF rather than the global table?
2. How do non-border leaves reach the internet without any L3Out config?
3. What route type carries an externally-learned default across the fabric?
4. A tenant can reach the internet but return traffic fails — where do you look?

---

**Next:** Session 9 — **Multi-site / DCI** — stitching two fabrics together with
border gateways so tenants span data centers.
