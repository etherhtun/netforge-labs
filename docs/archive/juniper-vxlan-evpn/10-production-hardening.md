# Session 10 — Production Hardening

> **Goal:** take the fabric from *"works in a lab"* to *"deploy it in production."*
> The earlier sessions kept configs minimal so the *concepts* were clear. Real
> deployments add MTU, fast failure detection, control-plane protection,
> authentication, and guard-rails. This session is the **delta** — apply it on top
> of any lab.

*Prerequisite: a working fabric (Sessions 1–4 at least).*

---

## 1. Why harden?

A demo fabric forwards packets. A **production** fabric must also: survive failures
in **sub-second** time, carry **full-size** frames, resist **attack and
misconfiguration** on the control plane, and **fail safe** when something floods or
misbehaves. Skipping these is how a fabric that "worked in testing" melts down on
day one. Each item below is a *why* + the config.

---

## 2. MTU — the one that silently breaks real traffic ⚠️

**Why:** VXLAN adds ~50 bytes. A 1500-byte tenant frame becomes ~1550 on the fabric.
A default-MTU underlay drops or fragments it — **ping works, real traffic breaks.**
The single most common "it passed testing then failed in prod" bug.

**Every fabric link gets jumbo MTU:**
```
set interfaces ge-0/0/0 mtu 9216
set interfaces ge-0/0/1 mtu 9216
```
Set it on **all** spine-leaf links (and the IRB/host side sized appropriately).
Verify: `show interfaces ge-0/0/0 | match MTU`.

## 3. BFD — sub-second failure detection

**Why:** default protocol timers detect a dead neighbour in *seconds* (OSPF ~40s,
BGP ~90s hold). **Bidirectional Forwarding Detection** detects a dead path in
**~milliseconds**, so traffic reroutes almost instantly.

**Underlay (OSPF) and overlay (BGP):**
```
set protocols ospf area 0 interface ge-0/0/0.0 bfd-liveness-detection minimum-interval 300
set protocols ospf area 0 interface ge-0/0/1.0 bfd-liveness-detection minimum-interval 300
set protocols bgp group overlay bfd-liveness-detection minimum-interval 300
```
Verify: `show bfd session`.

## 4. Control-plane protection (lo0 filter / CoPP)

**Why:** the routing engine (control plane) must be shielded from floods and
spoofed traffic. A **loopback firewall filter** polices what can reach the RE —
permit BGP/OSPF/BFD/SSH/ICMP from expected sources, rate-limit the rest, deny
everything else.

```
set firewall family inet filter PROTECT-RE term ok from protocol [ ospf tcp icmp ]
set firewall family inet filter PROTECT-RE term ok then accept
set firewall family inet filter PROTECT-RE term rest then policer LIMIT
set firewall family inet filter PROTECT-RE term rest then discard
set firewall policer LIMIT if-exceeding bandwidth-limit 2m burst-size-limit 15k
set firewall policer LIMIT then discard
set interfaces lo0 unit 0 family inet filter input PROTECT-RE
```
> Tune the terms to your real control-plane protocols/sources — this is a sketch.

## 5. BGP / OSPF authentication

**Why:** stop a rogue device from forming an adjacency and injecting routes.
```
set protocols bgp group overlay authentication-key "<secret>"      # or a keychain
set protocols ospf area 0 interface ge-0/0/0.0 authentication md5 1 key "<secret>"
```

## 6. Guard-rails — prefix limits, storm control, MAC limits

**Why:** contain the blast radius when something goes wrong (a route leak, a
broadcast storm, a runaway host).
```
# cap EVPN routes from a peer (protect the table)
set protocols bgp group overlay family evpn signaling prefix-limit maximum 20000 teardown 80
# limit broadcast/unknown storms on access ports
set forwarding-options storm-control-profiles SC all bandwidth-percentage 5
set interfaces ge-0/0/2 unit 0 family ethernet-switching storm-control SC
# cap MACs learned on an access port (stop MAC-flooding)
set switch-options interface ge-0/0/2.0 interface-mac-limit 200 packet-action drop
```

## 7. Fast, graceful convergence

**Why:** keep forwarding during control-plane restarts and tune timers for quick,
stable reconvergence.
```
set routing-options graceful-restart
set protocols bgp group overlay hold-time 30            # tighter than default 90
```

## 8. Addressing & naming discipline (operability)

**Why:** a fabric you can't read is a fabric you can't troubleshoot at 3 a.m.
- A **consistent RD/RT scheme** — RD = `<loopback>:<vni-index>`, RT per-VNI/tenant
  by convention (or auto-derived), documented in one place (the IP plan).
- **Interface descriptions** on every link (`set interfaces ge-0/0/0 description "to spine1"`).
- Consistent VLAN/VNI numbering (`L2VNI = 10000+VLAN`, `L3VNI = 50000+tenant`).

## 9. The production checklist

Redundancy (no single point of failure):

- [ ] **Two spines**, **two route reflectors** (or eBGP), every leaf peers with both
- [ ] **Two border leaves** for L3-out; **two BGWs** per site for multi-site
- [ ] Critical hosts **dual-homed** (ESI, Session 6)

Hardening on every device:

- [ ] Jumbo **MTU 9216** on all fabric links
- [ ] **BFD** on underlay + overlay
- [ ] **lo0 control-plane filter** (CoPP)
- [ ] **BGP/OSPF authentication**
- [ ] **Prefix-limits**, **storm-control**, **MAC limits**
- [ ] **Graceful restart**, tuned timers
- [ ] Interface **descriptions**, documented RD/RT/VNI scheme
- [ ] NTP, syslog, and telemetry configured (out of scope here, but required)

---

## 10. Verify

```
show interfaces ge-0/0/0 | match MTU        → 9216
show bfd session                            → Up sessions on underlay + overlay
show firewall filter PROTECT-RE             → counters incrementing on the RE filter
show bgp neighbor <peer> | match Authentication   → enabled
```

## 11. Break & observe

- **Fail a link with vs without BFD** — time the reconvergence. With BFD it's
  sub-second; without, several seconds of blackhole. The clearest demo of why BFD
  matters.
- **Send oversized traffic without jumbo MTU** — small pings pass, a 9000-byte flow
  fails. Then set MTU 9216 and it works. The MTU lesson, made visceral.

---

## 12. Lessons & interview

- **MTU and BFD are non-negotiable** in a real fabric — MTU for correctness, BFD for
  convergence. Most "worked in the lab" failures trace to one of these.
- **Protect the control plane** (lo0 filter, auth) and **cap the blast radius**
  (prefix-limits, storm-control) — a production fabric fails *safe*.
- Operability (naming, a documented RD/RT scheme) is part of "production-grade," not
  an afterthought.

**⚠️ Validation status:** these are standard Junos hardening patterns; validate the
exact syntax/values against your platform and scale before rollout.

**Interview questions:**
1. Why must fabric links use jumbo MTU, and what's the classic symptom if they don't?
2. How does BFD change convergence, and where do you enable it in an EVPN fabric?
3. What is a loopback (CoPP) filter protecting, and name three things it should permit?
4. Name three "blast-radius" guard-rails and what each contains.
5. You're handed a fabric that "works but flaps under load." What hardening would you check first?

---

**Next:** Session 11 — **MAC mobility & duplicate detection** (what happens when a
VM moves, and how EVPN prevents loops/duplicate MACs).
