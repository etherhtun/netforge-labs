# Break-it exercises — Lab 02 (RR)

Understanding comes from watching things fail. For each exercise: **predict the
symptom first**, then break it, then find the `show` command that exposes it, then
fix it. Always reverse a break before the next one.

## 1. Kill one spine (RR redundancy)
On **spine1**: `deactivate protocols bgp` then `commit`.

- **Predict:** does the overlay survive? Do hosts still ping?
- **Why:** each leaf peers with *both* spines, so the second RR still reflects
  everything. This is the whole point of two RRs.
- **Check:** on leaf1, `show bgp summary` — the session to `10.0.0.11` drops, but
  `10.0.0.12` stays `Establ`. Hosts keep pinging.
- **Fix:** `activate protocols bgp` on spine1, `commit`.

## 2. Forget the `cluster` on a spine
On **spine1**: `delete protocols bgp group overlay cluster 10.0.0.11`, `commit`.

- **Predict:** without a cluster id, is spine1 still a route reflector?
- **Why:** `cluster` is what makes it an RR. Without it, spine1 is a plain iBGP
  peer — and plain iBGP does **not** re-advertise a route learned from one iBGP
  peer to another. So leaf1's routes won't reach leaf2 via spine1.
- **Check:** on spine1, routes still arrive in `bgp.evpn.0`, but leaf2 stops
  seeing leaf1's Type-2/Type-3 (unless spine2 still reflects). With only this RR,
  the far leaf loses routes.
- **Fix:** re-add the `cluster`, `commit`.

## 3. Point a leaf at the wrong spine loopback
On **leaf1**: change a neighbor to a non-existent IP.

- **Predict:** session state?
- **Check:** `show bgp summary` → that peer never leaves `Connect`/`Active`.
- **Fix:** restore the correct spine loopback.

## 4. Mismatch the VNI between leaves
On **leaf2**: `set vlans v100 vxlan vni 10199`, `commit`.

- **Predict:** does the tunnel form? Do hosts ping?
- **Check:** `show evpn database` — the leaves now disagree on the VNI, so the
  L2 stretch breaks.
- **Fix:** set it back to `10100`.

## 5. Remove the VTEP source on a leaf
On **leaf1**: `delete switch-options vtep-source-interface`, `commit`.

- **Predict:** what happens to the Type-3 advertisement and the tunnel?
- **Check:** `show ethernet-switching vxlan-tunnel-end-point remote` — the tunnel
  drops; the leaf can no longer source VXLAN.
- **Fix:** `set switch-options vtep-source-interface lo0.0`, `commit`.

---

> The most instructive one is **#2** — it teaches *why* an RR exists at all:
> plain iBGP won't relay routes between peers, which is exactly the problem
> route reflection solves.
