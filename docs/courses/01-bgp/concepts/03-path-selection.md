# 3 · Best-path selection

When BGP has several paths to the same prefix, it picks exactly one as **best** —
that's the one installed in the routing table and the only one advertised onward.

This is the most-asked BGP interview topic. Learn the order, but more importantly
learn *why* each step is where it is.

---

## The algorithm

Compared top to bottom. **The first step that produces a difference decides it** —
nothing below is even evaluated.

| # | Step | Wins | Why here |
|---|---|---|---|
| 1 | **Weight** | highest | purely local override; not advertised |
| 2 | **Local preference** | highest | *your AS's* policy decision — outranks everything external |
| 3 | **Locally originated** | self > learned | your own route beats one that came back to you |
| 4 | **AS path length** | shortest | the closest thing BGP has to a distance metric |
| 5 | **Origin** | IGP < EGP < incomplete | a `network` statement is more trustworthy than a redistribution |
| 6 | **MED** | lowest | the neighbour's hint — considered only after your own policy |
| 7 | **eBGP over iBGP** | eBGP | leaving the AS directly beats crossing it first |
| 8 | **IGP metric to next hop** | lowest | **hot-potato** — nearest exit |
| 9 | **Oldest path** | oldest | stability tiebreak: don't churn for no reason |
| 10 | **Lowest router ID** | lowest | deterministic tiebreak |
| 11 | **Lowest neighbour IP** | lowest | final tiebreak |

!!! tip "Remembering it"
    **W**eight · **L**ocal-pref · **O**riginate · **A**S-path · **O**rigin ·
    **M**ED · **e**BGP · **I**GP metric · **O**ldest · **R**outer-ID ·
    **N**eighbour-IP.

    But the shape matters more than the mnemonic: **your policy first (1–3), then
    the path itself (4–6), then how you exit (7–8), then arbitrary tiebreaks
    (9–11).** If you understand that shape you can reconstruct the list.

---

## The four you'll actually use

Steps 9–11 are tiebreaks you rarely reach deliberately. In practice decisions are
made at:

**Step 2 — local preference.** The lever for "always prefer provider A." It beats
AS path, so a 5-hop path with local-pref 200 wins over a 1-hop path at 100. That's
the point: your commercial arrangement outranks topology.

**Step 4 — AS path length.** The default behaviour when no policy is applied, and
what prepending manipulates.

**Step 6 — MED.** Only between paths from the *same* neighbouring AS by default.

**Step 8 — IGP metric.** Hot-potato routing: when everything else ties, hand traffic
to the nearest exit and let the other AS carry it. Cheapest for you.

---

## Why order beats memorising

Two paths to `10.0.0.0/8`:

| | Path A | Path B |
|---|---|---|
| Local pref | **200** | 100 |
| AS path | `65001 65002 65003` (3) | `65004` (1) |
| MED | 500 | 50 |

**A wins**, at step 2. B's much shorter path and better MED are never compared,
because local preference already decided.

That's the most common real-world surprise: *"the shorter path isn't being used."*
Almost always, something set local-pref higher on the longer one.

Now the same two paths with local-pref equal at 100:

**B wins** at step 4 — shorter AS path. MED still never gets compared.

---

## Reading it on a device

```bash
show ip bgp 172.16.30.0/24
```

```
BGP routing table entry for 172.16.30.0/24
 Paths: 1 available
  65002
    10.0.13.3 from 10.0.13.3 (3.3.3.3)
      Origin IGP, metric 0, localpref 100, IGP metric 0, weight 0, tag 0
      Received 00:29:38 ago, valid, external, best
```

The three words at the end are the verdict:

- **`valid`** — the next hop resolves. Without this it can't be considered at all.
- **`external`** — learned via eBGP (step 7 relevance).
- **`best`** — this path won.

With multiple paths, compare them attribute by attribute down the list and the first
difference is your answer. In `show ip bgp`, `>` marks the best path and `*` marks
valid ones.

!!! warning "Only the best path is advertised"
    BGP tells peers about the winner and nothing else, so a route can be perfectly
    good and completely invisible downstream. When a neighbour "isn't receiving" a
    prefix you can see, check whether it's actually *best* on your router — not just
    present.

    This also means BGP shows the internet a consistent view: every router
    advertises one path per prefix.

---

## Multipath

By default BGP installs one path even when several are equally good. Wasteful when
you have two identical links to the same provider.

```
router bgp 65001
 maximum-paths 4
```

For paths to be candidates they must tie on everything down to the IGP metric, and
have the **same AS path length** — and, for eBGP, by default the same neighbouring
AS. `as-path multipath-relax` lifts that last requirement when you have equal links
to *different* ASes.

The best path is still chosen normally; multipath just installs the equal ones
alongside it. Only the best is advertised onward.

---

## Deterministic vs oldest-path

Step 9 — prefer the oldest path — exists for stability, but it makes the outcome
depend on **arrival order**. Two routers with identical tables can pick differently
because they learned things in a different sequence, which is unpleasant to debug.

`bgp deterministic-med` and related knobs make comparison order-independent at the
cost of a little churn. Worth knowing that the default trades determinism for
stability, and that this is a real source of "why do these two routers disagree?"

---

## Troubleshooting method

When the wrong path wins, walk the list in order and stop at the first difference:

```bash
show ip bgp <prefix>                    # all paths, all attributes
show ip bgp <prefix> detail             # more, including why not best
```

1. Different **weight**? Local to this router — check for a leftover override.
2. Different **local-pref**? Almost always the answer. Find the route-map.
3. Different **AS path length**? Expected behaviour; check for prepending.
4. Different **origin**? One side is redistributing (`?`).
5. Different **MED**? Only compared within the same neighbour AS.
6. Still tied? You're into IGP metric and arbitrary tiebreaks.

**Check steps 1–2 before anything else.** The overwhelming majority of "BGP is
choosing the wrong path" is local preference doing exactly what someone configured
it to do.

---

**Next:** [Policy and filtering →](04-policy.md) — how to set these attributes.
