# 2 · Path attributes

Every BGP route carries attributes. Policy sets them, the best-path algorithm
compares them. Understanding them is most of understanding BGP.

Here they are on a real route from the lab fabric:

```
BGP routing table entry for 172.16.30.0/24
 Paths: 1 available
  65002
    10.0.13.3 from 10.0.13.3 (3.3.3.3)
      Origin IGP, metric 0, localpref 100, IGP metric 0, weight 0, tag 0
      Received 00:29:38 ago, valid, external, best
```

`65002` is the AS path. Then origin, MED (shown as `metric`), local preference,
weight — and the verdict: `valid, external, best`.

---

## The four categories

The categories aren't trivia — they define what a router must do with an attribute
it doesn't recognise, which is what let BGP gain features like communities without
breaking older routers.

| Category | Must support? | Pass on if unknown? |
|---|---|---|
| **Well-known mandatory** | yes — must be in every update | n/a |
| **Well-known discretionary** | yes | n/a |
| **Optional transitive** | no | **yes**, marked partial |
| **Optional non-transitive** | no | **no**, dropped |

| Attribute | Category |
|---|---|
| ORIGIN, AS_PATH, NEXT_HOP | well-known mandatory |
| LOCAL_PREF, ATOMIC_AGGREGATE | well-known discretionary |
| COMMUNITY, extended communities | optional transitive |
| MED, ORIGINATOR_ID, CLUSTER_LIST | optional non-transitive |

!!! tip "Why optional transitive matters"
    A router that doesn't understand communities still **forwards** them, so a
    community you set survives crossing networks that don't use it. That property
    is what makes communities usable as an inter-provider signalling mechanism.

    MED is non-transitive by design — it's only meaningful between two directly
    adjacent ASes, so it shouldn't leak further.

---

## AS_PATH

The list of ASes a route has crossed. Two jobs:

**Loop prevention.** A router rejects any route whose AS path already contains its
own AS. This is why eBGP doesn't need a separate loop mechanism — and why iBGP,
which doesn't prepend, needs the full-mesh rule instead.

**Path length**, step 4 of best-path. Shorter usually wins.

**Prepending** is the standard way to make a path less attractive:

```
route-map PREPEND permit 10
 set as-path prepend 65001 65001 65001
```

Advertise the same prefix to two providers, prepending on the backup, and inbound
traffic prefers the shorter path.

!!! warning "Prepending is a blunt instrument"
    You're asking the entire internet to prefer another path, and anyone with local
    preference set on your prefixes ignores you completely — local-pref is compared
    at step 2, prepending at step 4.

    Prepending influences; it does not control. Communities that a provider has
    agreed to honour are more precise.

---

## NEXT_HOP

Where to send traffic for this prefix.

- **eBGP** — the advertising router sets it to itself
- **iBGP** — passed along **unchanged**

That second rule is Lab 01's trap. An iBGP peer receives a next hop belonging to a
link in someone else's AS, has no route to it, and the route is unusable.

**The route must be usable, not just present.** BGP considers a route valid if the
next hop resolves *at all* — including via a default route, which in a lab is often
the management interface. See [Lab 01 step 4](../lab-01-ebgp-ibgp.md).

Fix with `next-hop-self` on the border router.

---

## LOCAL_PREF

**Which exit this AS should use.** Higher wins. Default 100.

Sent between iBGP peers, never to eBGP peers — it's an internal decision, so it
propagates through your AS and stops at the boundary.

```
route-map PREFER_PRIMARY permit 10
 set local-preference 200
```

It's compared at **step 2**, so it beats AS path, MED and everything below. That
makes it the tool for "always use provider A while it's up," regardless of what the
paths look like.

**Local-pref controls outbound traffic** — your own routers use it to choose an
exit. It cannot influence what other people send you.

---

## MED

**Which entrance to use, when there are several into your AS.** Lower wins.

The mirror of local-pref: local-pref is your decision about leaving, MED is a
*suggestion* to your neighbour about entering.

Two things make MED awkward:

- **It's only compared between paths from the same neighbouring AS** by default.
  Comparing MEDs from different providers is meaningless — they're not the same
  scale — though `always-compare-med` will do it if you insist.
- **It's a request, not an instruction.** Your neighbour's local-pref is compared
  first and overrides it entirely.

If a provider ignores your MED, that's normal; MED is step 6.

---

## WEIGHT

**Local to one router, never advertised.** Highest wins, default 0 for learned
routes.

Originally Cisco, now widely implemented — Arista shows it in the output above.

Because it's step 1 and purely local, weight is a blunt override for a single
router. Prefer local-pref for anything that should apply AS-wide: weight affects
one box and silently does nothing on the others, which makes for confusing
troubleshooting.

---

## ORIGIN

How the route entered BGP. Compared at step 5, preference order:

| Code | Means |
|---|---|
| **i** (IGP) | a `network` statement — most preferred |
| **e** (EGP) | historical, effectively extinct |
| **?** (incomplete) | **redistributed** — least preferred |

Seen as `Origin IGP` in the capture above, and as a trailing `i` in `show ip bgp`.

The practical consequence: a redistributed route (`?`) loses to an otherwise equal
route from a `network` statement. If two paths tie until step 5 and the "wrong" one
wins, check whether one side is redistributing.

---

## COMMUNITY

A **tag** you attach to a route. It does nothing by itself — its value is that
policy elsewhere can match on it.

Written `AS:value`, e.g. `65001:100`.

Well-known values:

| Community | Effect |
|---|---|
| `NO_EXPORT` | don't advertise outside the AS (or confederation) |
| `NO_ADVERTISE` | don't advertise to **any** peer |
| `LOCAL_AS` | don't advertise outside the local sub-AS |

```
route-map TAG_CUSTOMER permit 10
 set community 65001:100
```

The real power is provider signalling: a transit provider publishes communities like
"set local-pref 80 on my routers" or "don't advertise to AS X," and you tag your
announcements accordingly. That gives precise control where prepending only gives a
nudge.

More in [policy and filtering](04-policy.md).

---

## Which attribute for which job

| You want to control | Use | Direction |
|---|---|---|
| Which exit **we** use | **LOCAL_PREF** | outbound traffic |
| Which entrance **they** use | **MED**, prepending, communities | inbound traffic |
| One router's local choice | WEIGHT | that router only |
| Stop a route spreading | COMMUNITY (`NO_EXPORT`) | advertisement scope |

!!! note "The asymmetry that trips people up"
    **You control what you send out easily, and what comes in only by persuasion.**

    Local-pref is authoritative — your routers obey it. Anything influencing inbound
    traffic (MED, prepending, communities) is a request to networks you don't
    operate, and they may have policy that overrides it.

---

**Next:** [Best-path selection →](03-path-selection.md) — the order all this is
compared in.
