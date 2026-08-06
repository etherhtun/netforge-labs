# 🧪 Lab 01 · Multi-Provider DIA & Traffic Engineering

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric.

**Time:** ~50 minutes · **Nodes:** 5 (2 Edge Routers, 2 Provider Transit Routers, 1 L2 Access Switch) + 3 Test Hosts

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/edge-lab
      ./run.sh 02          # apply + verify step 02 automatically
      ./run.sh --all       # run all steps in order
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-edge-lab-r1 Cli
      r1> enable
      r1# configure
      ```
      Or push individual step snippets using stdin:
      `docker exec -i clab-edge-lab-r1 Cli -p 15 < steps/02-r1-underlay.cfg`

---

## Topology & Addressing

```mermaid
graph TD
    subgraph ProviderA["Tier-1 ISP Provider A (AS 65002)"]
      R3["r3 · 10.0.13.3"]
    end
    subgraph ProviderB["Regional ISP Provider B (AS 65003)"]
      R4["r4 · 10.0.24.4"]
    end
    subgraph CustomerAS["Enterprise DIA Fabric (AS 65001)"]
      R1["r1 · 1.1.1.1"] ---|iBGP / OSPF| R2["r2 · 2.2.2.2"]
    end
    R1 ---|eBGP| R3
    R2 ---|eBGP| R4
    R3 ---|eBGP Peering| R4
    classDef n fill:#1565c0,stroke:#90caf9,color:#ffffff,stroke-width:2px,font-size:14px;
    classDef e fill:#2e7d32,stroke:#a5d6a7,color:#ffffff,stroke-width:2px,font-size:14px;
    class R1,R2 n; class R3,R4 e;
```

| Router | AS | Role | Subnet | Neighbor IP |
|---|---|---|---|---|
| **r1** | 65001 | Primary DIA Edge Router | `10.0.13.0/24` | `10.0.13.3` (r3) |
| **r2** | 65001 | Secondary DIA Edge Router | `10.0.24.0/24` | `10.0.24.4` (r4) |
| **r3** | 65002 | Provider A (Tier 1) | `10.0.13.0/24` | `10.0.13.1` (r1) |
| **r4** | 65003 | Provider B (Regional) | `10.0.24.0/24` | `10.0.24.2` (r2) |

---

## Step 1 · Egress Traffic Engineering (`LOCAL_PREF`)

By default, BGP path selection prefers shorter `AS_PATH`. To steer outbound traffic through Provider A (r3) regardless of path length, set `LOCAL_PREF` to 150 on r1 (default is 100).

```eos
! Applied on r1 (Primary DIA Edge)
router bgp 65001
   neighbor 10.0.13.3 route-map RM-SET-LP-IN in
!
route-map RM-SET-LP-IN permit 10
   set local-preference 150
```

**Verification:**

```bash
docker exec -i clab-edge-lab-r2 Cli -p 15 <<'EOF'
enable
show ip bgp 172.16.30.0/24
EOF
```

```
BGP routing table entry for 172.16.30.0/24
  Paths: 2 available
  Local
    1.1.1.1 (metric 20) from 1.1.1.1 (1.1.1.1)
      Origin IGP, metric 0, localpref 150, weight 0, valid, internal, best
      Path code: AS_PATH 65002 65003
```

✅ **DONE when** `localpref 150` path via `1.1.1.1` (r1) is selected as `best` on r2.

---

## Step 2 · Ingress Traffic Engineering (AS-Path Prepending & Communities)

To control inbound traffic from the Internet, use **AS-Path Prepending** or **BGP Community Signaling**.

### AS-Path Prepending
On r2 (Secondary DIA), prepend AS 65001 twice when advertising to Provider B (r4) so remote ASes prefer Provider A.

```eos
! Applied on r2
route-map RM-PREPEND-OUT permit 10
   set as-path prepend 65001 65001
!
router bgp 65001
   neighbor 10.0.24.4 route-map RM-PREPEND-OUT out
```

### Community-Based Signaling (`65000:70` & Large Communities RFC 8092)
Send standard communities (`65002:70`) and Large Communities (`65001:1000:70`) to signal upstream ISPs to depress Local Preference for secondary backup links.

```eos
! Standard & Large Community Tagging
ip community-list CL-BACKUP permit 65002:70
!
route-map RM-COMMUNITY-OUT permit 10
   set community 65002:70 additive
   set large-community 65001:1000:70 additive
```

**Verification:**

```bash
docker exec -i clab-edge-lab-r4 Cli -p 15 <<'EOF'
enable
show ip bgp 192.168.10.0/24
EOF
```

```
Path: 65001 65001 65001
Community: 65002:70
Large Community: 65001:1000:70
```

✅ **DONE when** Provider B (r4) sees the prepended AS-path and received BGP communities.

---

## 🧠 Google Network Infra Knowledge Sharing & Protocol Mechanics

> [!NOTE]
> ### 1. BGP Path Selection Decision Algorithm (Step-by-Step Hierarchy)
> When multiple routes exist for a destination prefix, Arista EOS / Cisco NX-OS evaluates the BGP Decision Process in strict sequence. The first tie-breaker that matches wins:
>
> | Step | Criteria | Default Value | Scope | Description |
> |:---:|---|:---:|:---:|---|
> | **1** | **Weight** (Cisco/Arista Proprietary) | `0` (Local: `32768`) | Local Router | Highest weight wins. Evaluated before anything sent to peers. |
> | **2** | **`LOCAL_PREF`** | `100` | iBGP Domain | **Highest `LOCAL_PREF` wins.** Used for Outbound Egress Traffic Engineering. |
> | **3** | **Self-Originated** | - | Local Router | Prefer routes locally originated via `network` or `redistribute` over received. |
> | **4** | **`AS_PATH` Length** | - | Global BGP | **Shortest `AS_PATH` length wins.** (Ignored if `bgp bestpath as-path ignore` is set). |
> | **5** | **Origin Code** | `IGP` | Global BGP | Prefer `IGP` (`i`) > `EGP` (`e`) > `Incomplete` (`?`). |
> | **6** | **`MED` (Multi-Exit Discriminator)**| `0` | Neighbor AS | **Lowest `MED` wins.** Only compared between paths from the *same* neighbor AS. |
> | **7** | **Peer Type** | - | Session | Prefer **eBGP** paths over **iBGP** paths. |
> | **8** | **IGP Metric to Next-Hop** | - | Underlay IGP | Prefer path with lowest IGP cost (OSPF/IS-IS) to reaching BGP `NEXT_HOP`. |
> | **9** | **Multipath / ECMP** | - | FIB | If equal up to Step 8 and `maximum-paths` configured, install parallel ECMP routes. |
> | **10** | **BGP Router ID** | - | Session | Prefer path from peer with lowest numerical BGP Router ID. |

> [!IMPORTANT]
> ### 2. Standard vs Large BGP Communities Wire Format (RFC 1997 vs RFC 8092)
>
> - **Standard Communities (RFC 1997)**:
>   - Size: **32 bits (4 bytes)** formatted as `16-bit ASN : 16-bit Action Value`.
>   - Limitation: Because modern Autonomous Systems use 32-bit 4-byte ASNs (e.g. Google `AS15169`, Cloudflare `AS13335`), a 4-byte ASN cannot fit into the 16-bit ASN field of a standard community!
>   - Example: `65002:70` (AS 65002, Action 70).
>
> - **Large BGP Communities (RFC 8092)**:
>   - Size: **96 bits (12 bytes)** formatted as three distinct 32-bit fields:
>     $$\text{Large Community} = [\text{32-bit Global Administrator}] : [\text{32-bit Action}] : [\text{32-bit Parameter / Target}]$$
>   - Example: `65001:1000:70` (`Global Admin: AS 65001`, `Action: Depress LocalPref`, `Target: Transit AS 70`).
>   - Advantage: Allows 4-byte ASN holders (like Google AS15169) to cleanly encode global intent, specific action codes, and target peer AS numbers without truncation or collision.

> [!TIP]
> ### 3. Asymmetric Routing & Stateful Security Engineering
>
> In multi-homed DIA environments, outbound packets often take Path A (via Provider A) while returning inbound packets take Path B (via Provider B).
>
> ```
> [Enterprise LAN] ──> Egress (r1 / Provider A) ──> [Target Web Server]
> [Enterprise LAN] <── Ingress (r2 / Provider B) <── [Target Web Server]  (Asymmetric!)
> ```
>
> - **Stateful Firewall Failure**: If stateful firewalls are placed behind edge routers without session synchronization, inbound packets taking Provider B will be dropped because Firewall B has no record of the TCP SYN handshake processed by Firewall A.
> - **Mitigation Strategies**:
>   1. **Asymmetric Routing Groups (ARG) / Stateful Session Sync**: Link firewalls in active-active HA clusters with dedicated sync links.
>   2. **Strict Symmetrical Ingress Steering**: Use BGP Large Communities and AS-Path Prepending to force remote ASes to send ingress traffic through the exact same edge router handling egress traffic.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```

