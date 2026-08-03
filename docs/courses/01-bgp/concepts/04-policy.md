# 4 · Policy and filtering

This is the half of BGP that isn't routing. Policy decides what you accept, what you
advertise, and how attractive each path looks.

---

## Prefix lists — which prefixes

Match on the prefix and its length.

```
ip prefix-list CUSTOMER-NETS seq 10 permit 172.16.0.0/16 le 24
ip prefix-list CUSTOMER-NETS seq 20 permit 10.0.0.0/8 le 24
ip prefix-list NO-BOGONS     seq 10 deny  10.0.0.0/8 le 32
ip prefix-list NO-BOGONS     seq 20 permit 0.0.0.0/0 le 24
```

The length modifiers do the work:

| Modifier | Matches |
|---|---|
| *(none)* | that prefix, that length exactly |
| `le 24` | that prefix, up to /24 |
| `ge 25` | that prefix, /25 and longer |
| `ge 8 le 24` | between /8 and /24 |

`permit 0.0.0.0/0` matches only the default route. `permit 0.0.0.0/0 le 32` matches
everything — a distinction that has caused real outages.

!!! warning "There is an implicit deny at the end"
    Anything not matched is denied. A prefix list that permits your customers and
    nothing else silently drops everything else — usually intended, occasionally
    catastrophic.

---

## Route maps — the policy engine

Ordered, numbered clauses. First match wins; processing stops there.

```
route-map CUSTOMER-IN deny 10
 match ip address prefix-list BOGONS

route-map CUSTOMER-IN permit 20
 match ip address prefix-list CUSTOMER-NETS
 set local-preference 200
 set community 65001:100

route-map CUSTOMER-IN deny 30
```

Read it as: drop bogons; accept customer prefixes and mark them; drop everything
else.

| Clause | Meaning |
|---|---|
| `permit` + match + set | matched routes accepted, attributes applied |
| `permit` with no match | matches **everything** |
| `deny` + match | matched routes dropped |
| *(end of map)* | **implicit deny** |

Applied per neighbour and per direction:

```
router bgp 65001
 neighbor 10.0.13.3 route-map CUSTOMER-IN in
 neighbor 10.0.13.3 route-map CUSTOMER-OUT out
```

!!! danger "A route-map with no matching clause denies everything"
    Forget the final `permit` and you drop the entire table. Applying an unfinished
    route-map to a production peer takes the session's routes to zero instantly.

    Build filters in the lab, and check with
    `show ip bgp neighbors <ip> received-routes` versus what's in the table.

---

## Communities

Tags that carry policy intent between routers and between organisations.

```
ip community-list standard CUSTOMER permit 65001:100

route-map PREFER permit 10
 match community CUSTOMER
 set local-preference 200
```

Send them explicitly — many implementations don't by default:

```
neighbor 10.0.13.3 send-community
```

**The pattern that scales:** tag on ingress, act on the tag everywhere else.

```
route-map FROM-CUSTOMER permit 10
 set community 65001:100      ! this came from a customer

route-map FROM-PEER permit 10
 set community 65001:200      ! this came from a settlement-free peer

route-map FROM-TRANSIT permit 10
 set community 65001:300      ! this came from a paid transit provider
```

Every other policy then matches communities rather than re-deriving where a route
came from. Adding a customer means one tag, not edits across every route-map — this
is how real networks stay maintainable.

Providers publish communities you can set on announcements to them — "set local-pref
80", "don't advertise to AS X", "prepend twice to peer Y". That gives you precise
control over inbound traffic where prepending is only a nudge.

---

## AS-path filtering

Match on the path with regex:

```
ip as-path access-list 1 permit ^$              # locally originated only
ip as-path access-list 2 permit ^65002$         # directly from AS 65002
ip as-path access-list 3 permit ^65002_         # originated by 65002, any distance
ip as-path access-list 4 deny   _65003_         # anything transiting 65003
```

| Regex | Matches |
|---|---|
| `^$` | empty path — your own routes |
| `^65002$` | exactly one AS |
| `^65002_` | path starts with 65002 |
| `_65003_` | 65003 anywhere in the path |

`^$` is the important one: **it's how a customer says "advertise only my own
prefixes, don't make me transit."** Applied outbound to your providers, it stops you
accidentally becoming a transit network — which is the mechanism behind a good number
of internet-scale outages.

---

## Operational safety

The controls that keep a peering from taking you down.

### Maximum prefix

```
neighbor 10.0.13.3 maximum-routes 100000 warning-limit 90000
```

A peer that leaks a full table at you can exhaust memory and take down every session.
Max-prefix tears down **that one** session instead.

**Set it on every eBGP peer.** A customer expected to send 10 prefixes should be
capped near that, not at a million.

### GTSM — better than ebgp-multihop

eBGP defaults to TTL 1, assuming a directly connected peer. Multihop peering needs
`ebgp-multihop`, which weakens that protection.

**GTSM** inverts the check — instead of "TTL must survive one hop," it requires the
arriving TTL to be *high*, which only a nearby sender can achieve:

```
neighbor 10.0.13.3 ttl maximum-hops 1
```

An off-path attacker's packets arrive with a lower TTL and are dropped in hardware,
before BGP processes them.

### BFD

Sub-second failure detection without making BGP timers fragile:

```
neighbor 10.0.13.3 bfd
```

BFD detects the failure in milliseconds and tells BGP to drop the neighbour —
far better than aggressive hold timers, which risk tearing down sessions under
transient load.

### Dampening

Suppresses a prefix that flaps repeatedly, with an exponentially decaying penalty.

Use it cautiously. Aggressive dampening was widely deployed, then largely rolled
back — the penalties suppressed legitimate prefixes for hours after brief instability
and made outages worse than the flapping did.

### Soft reconfiguration and route refresh

Changing an inbound policy means re-evaluating routes you've already received.

```
clear ip bgp 10.0.13.3 soft in       # route refresh — ask the peer to resend
```

Modern implementations negotiate the **route refresh capability**, so this is
non-disruptive. The older `soft-reconfiguration inbound` stores an unfiltered copy
locally at the cost of memory; you rarely need it now.

**Never `clear ip bgp *` on a production router.** It tears down every session and
re-converges the entire table — occasionally the right call, never the casual one.

---

## A sane eBGP template

```
router bgp 65001
 neighbor 10.0.13.3 remote-as 65002
 neighbor 10.0.13.3 description Transit-ProviderA
 neighbor 10.0.13.3 maximum-routes 1000000 warning-limit 900000
 neighbor 10.0.13.3 ttl maximum-hops 1
 neighbor 10.0.13.3 bfd
 neighbor 10.0.13.3 send-community
 address-family ipv4
  neighbor 10.0.13.3 activate
  neighbor 10.0.13.3 route-map TRANSIT-IN in
  neighbor 10.0.13.3 route-map TRANSIT-OUT out
```

!!! tip "Both directions, always"
    Every eBGP peer should have an inbound **and** an outbound policy. Inbound
    protects you from what they send; outbound protects everyone else from what you
    might accidentally announce.

    Most large-scale BGP incidents are a missing outbound filter — a network
    re-announcing routes it learned from one provider to another, becoming
    accidental transit for traffic it can't carry.

---

**Next:** [Scaling iBGP →](05-scaling.md).
