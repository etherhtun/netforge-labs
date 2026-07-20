# Session 9 — Multi-Site / DCI (stitching fabrics together)

> **Goal:** connect **two data-center fabrics** so tenants span both — for disaster
> recovery, geo-distribution, and workload mobility across sites — **without**
> merging them into one giant fragile failure domain. This is the capstone: EVPN
> Multi-Site with **Border Gateways**.

*Prerequisite: the whole course — this builds on everything.*

---

## 1. Mental model

Each site is a **gated community** (a full fabric from Sessions 1–8). Multi-site
connects two communities with a **secure highway (the DCI)** between them, and puts
a **border gateway (BGW)** at each community's edge — a *customs post*.

The customs post matters: it **re-packages** traffic at the border. Inside Site 1,
VXLAN tunnels are Site-1-local; the BGW terminates them and re-originates fresh
tunnels toward Site 2. Neither site's flooding, tunnels, or failures spill into the
other. Two connected communities — **not** one sprawling one. That containment is
the entire point.

---

## 2. Why before how

**Why multi-site instead of one big stretched fabric?**
You *could* stretch one fabric across sites, but then a broadcast storm, a bad
config, or a control-plane problem in one site takes down **both**. Multi-site
**contains the failure domain per site** while still allowing selected L2/L3 to
extend across. You get cross-site reachability with a firebreak in the middle.

**Why border gateways?**
Something must sit at the boundary to (a) decide what extends across sites and what
stays local, (b) handle BUM traffic between sites without duplicating it, and (c)
hide each site's internal VTEPs from the other. That's the BGW's job.

---

## 3. The mechanism (technical depth)

### Border Gateway — the boundary that re-originates
Unlike a route reflector (control-plane only, next-hop preserved), the **BGW is *in*
the data path between sites.** It **terminates** the local site's VXLAN and
**re-originates** the traffic toward the remote site — rewriting the next-hop to
**itself**. So:
- Remote sites see **one next-hop per site** (the BGW's multi-site loopback), not
  every internal leaf. The internal topology of each site is **hidden**.
- Each site's tunnels stay **local**; only the BGW-to-BGW path crosses the DCI.

### Site-internal vs site-external
The BGW runs EVPN two ways:
- **Site-internal:** normal EVPN with the local leaves/spines (it's a leaf-ish
  member of its own fabric).
- **Site-external:** EVPN (usually eBGP-EVPN) across the **DCI** to the other
  site's BGW, re-originating routes with next-hop = its own multi-site loopback.

### BUM across sites — controlled, de-duplicated
BUM (broadcast/unknown/multicast) must reach the other site **once**, not flooded
per leaf. The BGWs elect a **Designated Forwarder per site** for cross-site BUM, so
exactly one BGW forwards it across the DCI and injects it into the remote site.
This is what stops a broadcast in Site 1 from multiplying across Site 2.

### Anycast vs individual BGW
Sites usually run **two BGWs** sharing an **anycast multi-site loopback** for
redundancy and load-sharing — the remote site sees one stable next-hop even if a
BGW fails.

### What extends, and what doesn't
You choose per-VNI: some L2VNIs/L3VNIs are **stretched** across sites (a subnet
lives in both), others stay **local**. Type-2 (MAC) and Type-5 (prefix) routes are
selectively re-originated across the DCI for the VNIs you extend.

---

## 4. Build it

*(Lab 08 — Multi-Site — needs a **second fabric + DCI + BGWs**, a substantially
larger topology than the single-fabric labs. Built last, after the core is
validated. The design is shown here.)*

**Config sketch — a border gateway (conceptual):**
```
# Multi-site anycast loopback (shared by both BGWs in the site)
set interfaces lo0 unit 0 family inet address 10.0.2.100/32   # site-1 anycast BGW IP
# Mark this node a multi-site border gateway for the fabric's VNIs
set switch-options ... (multi-site BGW role)
# eBGP-EVPN across the DCI to the remote site's BGW, re-originating (next-hop self)
set protocols bgp group DCI type external
set protocols bgp group DCI family evpn signaling
set protocols bgp group DCI neighbor <remote-BGW-loopback> peer-as <remote-site-AS>
```
> Exact multi-site BGW syntax is platform/version-specific on Junos — this session
> teaches the *design*; the lab config is finalised against live vJunos when built.

---

## 5. Verify — and how to read it

**Cross-site reachability (a stretched VNI):**
```
site1-host> ping <site2-host in the same stretched subnet>   → success across the DCI
```
**Next-hop hiding:** on a Site-2 leaf, a Site-1 host's route shows next-hop = the
**Site-1 BGW anycast loopback**, *not* the individual Site-1 leaf. Confirms the BGW
re-originated and hid the internal topology.
**Containment:** a broadcast in Site 1 reaches Site 2 exactly once (via the DF BGW),
not multiplied.

---

## 6. Break & observe

- **Fail one BGW** (with two anycast BGWs) → cross-site traffic continues via the
  other; the remote site's next-hop (the anycast loopback) never changed.
- **Extend a VNI on one site only** → hosts in that VNI can't reach the other site;
  shows extension must be configured on both BGWs.

---

## 7. Lessons & interview

- The **BGW re-originates** traffic at the site boundary (next-hop = itself),
  **hiding** each site's internals and **containing** its failure domain — the
  opposite of a route reflector (which preserves next-hop and is control-plane only).
- **Per-site DF** controls cross-site BUM so broadcasts don't multiply.
- You choose per-VNI what stretches across sites.

**Interview questions:**
1. Why run EVPN Multi-Site instead of one stretched fabric across two DCs?
2. How does a BGW differ from a route reflector in next-hop handling, and why?
3. How is cross-site BUM kept from being duplicated in the remote site?
4. Why use an anycast loopback across the two BGWs in a site?
5. On a remote-site leaf, what next-hop do you expect for a host in the other site,
   and what does that tell you?

---

**🎓 That completes Course 1.** You've gone from a bare fabric to a multi-site,
multi-tenant, resilient VXLAN-EVPN data center — and you can explain and
troubleshoot every layer. Revisit the [Study primers](../study/index.md) and
[interview questions](../study/interview-questions.md) to lock it in.
