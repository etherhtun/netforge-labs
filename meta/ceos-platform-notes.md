# Arista cEOS — platform notes

Internal. Hard-won facts about the lab platform, extracted from CLAUDE.md so
that file stays a conventions document. Referenced from CLAUDE.md.

---

## Validated facts — Arista cEOS 4.32.0F (live, Apple Silicon / OrbStack)

**VXLAN-EVPN fabric validated end-to-end** (2 spine RR × 2 leaf VTEP + 2 hosts;
host↔host ping over VXLAN, Type-2/3 routes reflected with far-leaf next-hop).

Mandatory config that is easy to miss:

- **`ip routing`** — EOS defaults to an L2 switch. Without this, nothing routed works.
- **`service routing protocols model multi-agent`** — required for EVPN.
- OSPF via **interface-level** `ip ospf area 0.0.0.0` + `ip ospf network
  point-to-point`. The `network X/31 area …` form was flaky — don't use it.
- Single `Loopback0` = router-id + BGP update-source + `vxlan source-interface`.
- Spine RR: `neighbor <peer> route-reflector-client`; leaves peer both spines.

**Gotchas:**

- cEOS is **amd64-only** → runs under Rosetta on M-series. `docker import
  --platform linux/amd64` is mandatory (else `exec format error`).
- ⭐ **Link endpoints MUST be lowercase `ethN`** in `.clab.yml` — `["p1:eth1",
  "pe1:eth1"]`, never `Ethernet1`. cEOS's entrypoint counts `eth*` interfaces to know
  when wiring is done; a literal `Ethernet1` veth never matches, so it hangs on
  `Connected 0 interfaces out of N` forever and **EOS never boots** — which also
  makes `docker exec … Cli` fail with *"executable file not found"*. That error means
  **EOS hasn't started**, not that the image is broken. Inside EOS, `eth1` is
  `Ethernet1`.
- **Boot race:** with 4 nodes booting at once under emulation, a node can come up
  degraded — `show int Et1 status` shows type **`Unknown`**. `reload` is unsupported
  and **`docker restart` destroys the clab veths**. Fix = `containerlab destroy` +
  `deploy`, then **health-check every node** before configuring.
- ⭐ **Piping config in needs `docker exec -i`.** Without `-i` stdin is not attached,
  so a heredoc is silently discarded — the command exits 0, prints nothing, and
  **applies no configuration**. Looks identical to success. Use
  `docker exec -i <node> Cli -p 15 <<'EOF' … EOF`. (`-c "show …"` doesn't need it.)
- **LDP needs an interface-derived identity:** a bare `router-id 1.1.1.1` under
  `mpls ldp` is not enough — EOS reports *"TransportAddr interface not configured and
  router-id not derived from an interface"* and LDP stays operationally down. Use
  `router-id interface Loopback0` + `transport-address interface Loopback0`.
- Config entry: `docker exec -it clab-<fabric>-<node> Cli` → `enable` → `configure`.
  EOS applies live; `write memory` to persist.
- **Safe capability probing:** `configure session <name>` … `show session-config
  diffs` … `abort` — tests syntax without touching the running config.

### Capability probe — MPLS / SR / L3VPN (2026-08-02)

Probed via abortable config sessions on cEOS 4.32.0F. Sanity check confirmed invalid
commands *do* error, so "accepted" is meaningful.

| Feature | Verdict |
|---|---|
| `mpls ip`, `mpls ldp` | ✅ accepted (LdpAgent needs starting) |
| BGP `address-family vpn-ipv4` / `vpn-ipv6` | ✅ accepted (weak evidence — empty diff) |
| `vrf instance` + `rd` + `route-target import vpn-ipv4` | ✅ accepted — full L3VPN syntax |
| IS-IS / OSPF `segment-routing mpls` | ✅ accepted |
| `mpls rsvp` | ✅ accepted (weak evidence) |
| EVPN-VPWS `patch panel` / `connector` | ✅ accepted |
| **SRv6** | ❌ rejected — plan around its absence (cRPD is the fallback) |

### LDP live test — 3-node scratch fabric (2026-08-02)

Ran `pe1 — p1 — pe2` with OSPF + LDP (see `docs/courses/03-mpls-l3vpn/lab-01-mpls-ldp.md`).

**Confirmed working:**

- OSPF adjacencies `FULL`; loopbacks advertised and reachable.
- **LDP sessions reach `oper`** on both peers (TCP/646), discovery on both links.
- **Label bindings exchanged correctly** — pe1 learned label `100001` for
  `3.3.3.3/32` from p1, with `imp-null` where PHP applies.
- ⭐ **MPLS forwarding state IS programmed in the data plane.** p1's MPLS
  forwarding table holds two entries with *resolved adjacencies* — next-hop MAC,
  VLAN, egress interface, `EgressACL: apply`. That is real forwarding
  programming, not control-plane bookkeeping.

**Still unproven:** that labelled packets actually traverse. A loopback-to-loopback
ping succeeded (0% loss) but `traceroute` showed **plain IP hops, no label stack** —
expected, because nothing forces label imposition. LDP builds the LSP; only a
*service* (L3VPN / pseudowire) steers traffic into it.

**→ The remaining test is a minimal L3VPN** (VRF + VPNv4, CE-to-CE), where labels
are mandatory. That is Phase 3's opening lab anyway, so it doubles as content.
Risk of failure now looks **low** — the hard parts (LDP, label distribution, FIB
programming) all work — but it is not zero, so build Phase 3 lab-first and confirm
before writing sessions around it.

---

