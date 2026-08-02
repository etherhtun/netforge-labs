# Task #1 — MPLS Data-Plane Forwarding Test

**Question:** can cEOS 4.32.0F actually *forward* MPLS-labelled packets, or does it
only accept the configuration? This decides whether Phase 3 (MPLS & L3VPN) and
Phase 3.5 (Segment Routing) get built on cEOS or on cRPD.

**Topology:** `pe1 --- p1 --- pe2` — a separate scratch fabric. Never touch the
validated `ceos-evpn` one.

| Node | Loopback0 | Links |
|---|---|---|
| p1 | 1.1.1.1/32 | Et1 → pe1 (10.1.1.1/24) · Et2 → pe2 (10.1.2.1/24) |
| pe1 | 2.2.2.2/32 | Et1 → p1 (10.1.1.2/24) |
| pe2 | 3.3.3.3/32 | Et1 → p1 (10.1.2.2/24) |

!!! danger "Two traps that already cost an evening"
    **1. Link endpoints must be lowercase `ethN`.** cEOS counts `eth*` interfaces to
    know when containerlab has finished wiring. Naming one `Ethernet1` makes it hang
    on `Connected 0 interfaces out of N` forever — EOS never boots, and
    `docker exec … Cli` then fails with *"executable file not found"*. That error
    means **EOS hasn't started**, not that the image is broken.

    **2. Piping config in requires `docker exec -i`.** Without `-i`, stdin is never
    attached, the heredoc is silently discarded, and the command **exits 0 having
    applied nothing** — indistinguishable from success. Every config block below
    uses `-i`. Don't drop it.

---

## 1. Deploy

```bash
mkdir -p ~/mpls-scratch && cd ~/mpls-scratch && cat > topology.clab.yml <<'EOF'
name: ceos-mpls-scratch
topology:
  nodes:
    p1:
      kind: arista_ceos
      image: ceos:4.32.0F
    pe1:
      kind: arista_ceos
      image: ceos:4.32.0F
    pe2:
      kind: arista_ceos
      image: ceos:4.32.0F
  links:
    - endpoints: ["p1:eth1", "pe1:eth1"]
    - endpoints: ["p1:eth2", "pe2:eth1"]
EOF
```

If a previous attempt left containers behind, clear them first:

```bash
sudo containerlab destroy -t ~/mpls-scratch/topology.clab.yml --cleanup
```

Deploy one node at a time — concurrent boot under Rosetta is what triggers the
boot race:

```bash
cd ~/mpls-scratch && sudo containerlab deploy -t topology.clab.yml --max-workers 1
```

---

## 2. Health check — before configuring anything

```bash
for n in p1 pe1 pe2; do echo "===== $n ====="; docker exec clab-ceos-mpls-scratch-$n Cli -p 15 -c "show interfaces status"; done
```

**✅ DONE when:** every `Et*` port shows type **`EbraTestPhyPort`**.

A node showing type **`Unknown`** lost the boot race. Destroy, redeploy, re-check —
a degraded node accepts config and then silently never forms an adjacency, which
sends you hunting a protocol bug that isn't there.

---

## 3. Configure

One block per node — interfaces, OSPF and LDP together.

### p1 (core)

```bash
docker exec -i clab-ceos-mpls-scratch-p1 Cli -p 15 <<'EOF'
enable
configure
ip routing
service routing protocols model multi-agent
mpls ip
interface Loopback0
 ip address 1.1.1.1 255.255.255.255
interface Ethernet1
 no switchport
 no shutdown
 ip address 10.1.1.1 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
interface Ethernet2
 no switchport
 no shutdown
 ip address 10.1.2.1 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
router ospf 1
 router-id 1.1.1.1
 no shutdown
mpls ldp
 router-id interface Loopback0
 transport-address interface Loopback0
 no shutdown
end
write memory
EOF
```

### pe1

```bash
docker exec -i clab-ceos-mpls-scratch-pe1 Cli -p 15 <<'EOF'
enable
configure
ip routing
service routing protocols model multi-agent
mpls ip
interface Loopback0
 ip address 2.2.2.2 255.255.255.255
interface Ethernet1
 no switchport
 no shutdown
 ip address 10.1.1.2 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
router ospf 1
 router-id 2.2.2.2
 no shutdown
mpls ldp
 router-id interface Loopback0
 transport-address interface Loopback0
 no shutdown
end
write memory
EOF
```

### pe2

```bash
docker exec -i clab-ceos-mpls-scratch-pe2 Cli -p 15 <<'EOF'
enable
configure
ip routing
service routing protocols model multi-agent
mpls ip
interface Loopback0
 ip address 3.3.3.3 255.255.255.255
interface Ethernet1
 no switchport
 no shutdown
 ip address 10.1.2.2 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
router ospf 1
 router-id 3.3.3.3
 no shutdown
mpls ldp
 router-id interface Loopback0
 transport-address interface Loopback0
 no shutdown
end
write memory
EOF
```

`Copy completed successfully` at the end means the config was written. A silent
return with no output means it did **not** apply.

---

## 4. Confirm the config actually landed

Never skip this — it's the only defence against a silently discarded heredoc.

```bash
for n in p1 pe1 pe2; do echo "===== $n ====="; docker exec clab-ceos-mpls-scratch-$n Cli -p 15 -c "show ip interface brief"; done
```

**✅ DONE when:** each node shows its Loopback0 address and its Ethernet
address(es). Anything missing → re-run that node's block from step 3.

Then restart the LDP agent so it picks up the interface-derived router-id (EOS
warns *"Change will take effect on the next agent start"*):

```bash
for n in p1 pe1 pe2; do docker exec clab-ceos-mpls-scratch-$n Cli -p 15 -c "enable" -c "agent LdpAgent terminate"; done
```

---

## 5. Verify — in order; each step gates the next

### Step 1 · OSPF adjacency

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 -c "show ip ospf neighbor"
```

**✅ DONE when:** both neighbours (2.2.2.2 and 3.3.3.3) show state **`FULL`**.

Nothing below can work until this passes — LDP peers over the routed path.

### Step 2 · LDP session

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 -c "show mpls ldp discovery" -c "show mpls ldp neighbor"
```

**✅ DONE when:** both peers show **`Established`**. This proves the LDP **control
plane** works.

### Step 3 · Label allocation

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 -c "show mpls route"
```

```bash
docker exec clab-ceos-mpls-scratch-pe1 Cli -p 15 -c "show mpls route"
```

**✅ DONE when:** entries exist for the remote loopbacks (`2.2.2.2/32`,
`3.3.3.3/32`) with in/out labels. Still control plane — labels being *allocated*
is not the same as labels being *forwarded*.

### Step 4 · ⭐ The actual data-plane test

This is the whole point of the task.

```bash
docker exec clab-ceos-mpls-scratch-pe1 Cli -p 15 -c "ping 3.3.3.3 source 2.2.2.2"
```

```bash
docker exec clab-ceos-mpls-scratch-pe2 Cli -p 15 -c "ping 2.2.2.2 source 3.3.3.3"
```

**✅ DONE when:** both directions return **0% packet loss**.

Then confirm the forwarding table is actually programmed, rather than traffic
falling back to plain IP:

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 -c "show mpls lfib route"
```

```bash
docker exec clab-ceos-mpls-scratch-pe1 Cli -p 15 -c "traceroute 3.3.3.3 source 2.2.2.2"
```

---

## 6. Record the result

Paste back **Step 3** and **Step 4** — those two outputs are the proof.

| Outcome | Meaning | Next |
|---|---|---|
| Steps 1–4 all pass | MPLS forwards on cEOS | Phases 3 + 3.5 build on cEOS |
| Steps 1–3 pass, **Step 4 fails** | control plane only, no data plane | Phases 3 + 3.5 move to **cRPD** |
| Step 1 or 2 fails | config/protocol problem, not a platform verdict | fix, re-run, don't conclude yet |

The middle row is the one to watch for — it looks like success right up until
traffic has to move.

---

## 7. Teardown

```bash
sudo containerlab destroy -t ~/mpls-scratch/topology.clab.yml --cleanup
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Connected 0 interfaces out of N`, forever | endpoints named `Ethernet1` instead of `eth1` | fix topology, destroy + redeploy |
| `docker exec … Cli` → *executable file not found* | EOS never booted (see above) — not an image problem | fix the wiring, redeploy |
| Heredoc returns instantly, nothing applied | missing `-i` on `docker exec` | add `-i` |
| Port type `Unknown` | boot race under emulation | destroy + redeploy with `--max-workers 1`. **Never `docker restart`** — it destroys the clab veths, and `reload` isn't supported in a container |
| *LDP is operationally down: TransportAddr interface not configured* | bare `router-id 1.1.1.1` gives LDP no interface to source from | `router-id interface Loopback0` + `transport-address interface Loopback0` |
| *Change will take effect on the next agent start* | LdpAgent not running yet | `agent LdpAgent terminate` to respawn it |
| OSPF never reaches `FULL` | port still L2 | `no switchport` on the routed ports |
| `show mpls route` empty but LDP established | labels not allocated | check `mpls ip` is set globally on every node |
| Ping fails but labels present | **the real finding** | record it — Phases 3/3.5 move to cRPD |
