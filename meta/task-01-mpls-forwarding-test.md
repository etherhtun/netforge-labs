# Task #1 — MPLS Data-Plane Forwarding Test

**Goal:** Determine if cEOS 4.32.0F can forward MPLS-labelled packets end-to-end.
This unblocks Phases 3 (L3VPN) and 3.5 (Segment Routing).

**Outcome:** Update CLAUDE.md capability table with real result (✅ forwarding works OR ❌ forwarding fails).

**Estimated time:** 30 minutes.

---

## Setup

Build a **3-node scratch topology** (do NOT modify the validated ceos-evpn fabric).

```bash
ssh orb
mkdir -p ~/mpls-scratch && cd ~/mpls-scratch
```

### Topology file: `topology.clab.yml`

```yaml
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
    - endpoints: ["p1:Ethernet1", "pe1:Ethernet1"]
    - endpoints: ["p1:Ethernet2", "pe2:Ethernet1"]
```

### Deploy

```bash
sudo containerlab deploy -t topology.clab.yml
```

Wait ~5–10 min for boot under Rosetta emulation.

---

## Health check (before configuring)

```bash
for n in p1 pe1 pe2; do
  echo "=== $n ===";
  docker exec clab-ceos-mpls-scratch-$n Cli -p 15 -c "show interfaces Ethernet1 status" | head -3
done
```

Every node must show **Ethernet1 connected with type `EbraTestPhyPort`** (not `Unknown`).

If you see `Unknown`: `containerlab destroy -t topology.clab.yml` + `deploy`, then re-check.

---

## Configuration

**Apply this to all three nodes.** Each node's commands are independent (no ordering).

### P1 (core router)

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 <<'EOF'
enable
configure
no ip routing
ip routing
service routing protocols model multi-agent
!
mpls ip
!
interface Loopback0
 ip address 1.1.1.1 255.255.255.255
!
interface Ethernet1
 no shutdown
 ip address 10.1.1.1 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
!
interface Ethernet2
 no shutdown
 ip address 10.1.2.1 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
!
router ospf 1
 router-id 1.1.1.1
 no shutdown
!
mpls ldp
 router-id 1.1.1.1
 no shutdown
!
end
write memory
exit
EOF
```

### PE1

```bash
docker exec clab-ceos-mpls-scratch-pe1 Cli -p 15 <<'EOF'
enable
configure
no ip routing
ip routing
service routing protocols model multi-agent
!
mpls ip
!
interface Loopback0
 ip address 2.2.2.2 255.255.255.255
!
interface Ethernet1
 no shutdown
 ip address 10.1.1.2 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
!
router ospf 1
 router-id 2.2.2.2
 no shutdown
!
mpls ldp
 router-id 2.2.2.2
 no shutdown
!
end
write memory
exit
EOF
```

### PE2

```bash
docker exec clab-ceos-mpls-scratch-pe2 Cli -p 15 <<'EOF'
enable
configure
no ip routing
ip routing
service routing protocols model multi-agent
!
mpls ip
!
interface Loopback0
 ip address 3.3.3.3 255.255.255.255
!
interface Ethernet1
 no shutdown
 ip address 10.1.2.2 255.255.255.0
 ip ospf area 0.0.0.0
 ip ospf network point-to-point
!
router ospf 1
 router-id 3.3.3.3
 no shutdown
!
mpls ldp
 router-id 3.3.3.3
 no shutdown
!
end
write memory
exit
EOF
```

---

## Verification (run these in order)

### Step 1 — OSPF neighbors formed?

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 -c "show ip ospf neighbor"
```

**✅ DONE when:** All neighbors show State = **`Full`**.

### Step 2 — LDP neighbors established?

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 -c "show mpls ldp neighbor"
```

**✅ DONE when:** Both peers show State = **`Established`**.

### Step 3 — Labels allocated and swapped?

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 -c "show mpls route"
```

**✅ DONE when:** You see labels for loopback prefixes from both PE1 and PE2. Format should be something like:

```
Prefix     	OutLabel	NextHop       	Label In	State      	Tunnel    	Forwarding
2.2.2.2/32 	16       	10.1.1.2      	17       	ESTABLISHED	UNKNOWN   	N/A
3.3.3.3/32 	17       	10.1.2.2      	16       	ESTABLISHED	UNKNOWN   	N/A
```

(Exact numbers and order may vary.)

### Step 4 — Loopback reachability (labeled)

```bash
docker exec clab-ceos-mpls-scratch-pe1 Cli -p 15 -c "ping 3.3.3.3"
```

**✅ DONE when:** Ping succeeds from PE1 to PE2's loopback (0% loss).

```bash
docker exec clab-ceos-mpls-scratch-pe2 Cli -p 15 -c "ping 2.2.2.2"
```

**✅ DONE when:** Ping succeeds from PE2 to PE1's loopback (0% loss).

---

## Teardown

```bash
sudo containerlab destroy -t topology.clab.yml
```

---

## Result

### If all four steps passed (✅ DONE)

**MPLS forwarding works on cEOS.**

Update `CLAUDE.md` capability table:

```markdown
| **MPLS (end-to-end forwarding)** | ✅ confirmed — OSPF + LDP neighbor formation, label allocation + swapping, loopback reachability across fabric |
```

Then proceed: Phases 3 and 3.5 are built on cEOS.

### If any step failed (❌ FAILED)

**MPLS forwarding does not work on cEOS.** Record which step failed:

```markdown
| **MPLS (end-to-end forwarding)** | ❌ failed at Step [N]: [symptom]. Control plane works (step [M] passed) but data plane does not forward. |
```

Then: Use **cRPD** (junos-routing-crpd-docker-amd64-23.2R1.13.tgz) for Phases 3 and 3.5 instead. cRPD is a control-plane-only container — perfect for MPLS/L3VPN/SR since it doesn't need a data plane (you're teaching control plane, not packet forwarding anyway).

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `docker exec: command not found` | cEOS is still booting under Rosetta (slow!) | Wait 10 min, retry |
| `show ip ospf neighbor` = empty | OSPF not forming | Check interfaces are `up/up` with `show interface Ethernet1` before running OSPF |
| `show mpls ldp neighbor` = empty | LDP not starting after OSPF | Commit `mpls ldp` config again; check `router-id` is set |
| `show mpls route` = no entries | Labels not being allocated | LDP should auto-allocate once neighbors establish; if still empty, check `mpls ip` is global |
| Ping fails (100% loss) | Labels allocated but not forwarded | Data-plane issue — this is the critical unknown. Record the exact symptom and note in CLAUDE.md |
| Boot race: `show interfaces Ethernet1` shows type `Unknown` | cEOS race condition on concurrent boot | `containerlab destroy` + `deploy`, then health-check until all nodes show real type |

---

## Report back

Once done, paste the output of Step 3 (`show mpls route` on P1) and Step 4 (ping results from both PEs) — those are the proof points for either outcome.

Then I'll update CLAUDE.md and task #1 will be complete.
