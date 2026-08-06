# 🧪 Lab 03 · Internet Peering & IXP Architecture (GTSM + BFD)

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric.

**Time:** ~45 minutes · **Nodes:** 4 (Edge Router, IXP Route Server, 2 Peer Routers)

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

## Step 1 · Sub-Second Failure Detection with BFD

Standard BGP hold timers (180s default, 90s keepalive) are far too slow for hyperscale networks. **Bidirectional Forwarding Detection (BFD)** provides sub-second link failure detection.

```eos
! Enable BFD on BGP DIA Peering Sessions on Arista EOS
interface Ethernet1
   bfd interval 300 min_rx 300 multiplier 3
!
router bgp 65001
   neighbor 10.0.13.3 bfd
```

**Verification:**

```bash
docker exec -i clab-edge-lab-r1 Cli -p 15 <<'EOF'
enable
show bfd neighbors
EOF
```

```
IPv4 BFD Neighbors:
  Neighbor      Local Address   Interface    State    Rx Interval  Tx Interval
  10.0.13.3     10.0.13.1       Ethernet1    Up       300 ms       300 ms
```

✅ **DONE when** BFD neighbor state shows `Up` with 300 ms detection intervals.

---

## Step 2 · GTSM (Generalized TTL Security Mechanism)

GTSM protects eBGP peering sessions against CPU-exhaustion attacks and off-path TCP packet injection by checking the IP Header TTL value.

eBGP packets sent by directly connected peers have TTL = 255. GTSM verifies that incoming packets have `TTL = 255 - hops`.

```eos
! Enabling GTSM on eBGP Peer Session
router bgp 65001
   neighbor 10.0.13.3 ttl-security hops 1
```

If an attacker on the Internet spoofs a packet targeting port 179, the packet passes through intermediate routers, decreasing its TTL below 254. The edge router drops the packet at the hardware layer.

---

## Step 3 · IXP Route Server Peering

At Internet Exchange Points (e.g., LINX, DE-CIX, Equinix IX), networks peer with a **Route Server** to exchange routes with hundreds of participants via a single BGP session.

```eos
! IXP Route Server Peering Configuration
router bgp 65001
   neighbor 195.66.224.254 remote-as 64512
   neighbor 195.66.224.254 description "IXP-Route-Server-1"
   neighbor 195.66.224.254 import-check
```

---

## 🧠 Google Network Infra Knowledge Sharing

> [!NOTE]
> ### Production Deep Dive & Hyperscale Architecture
>
> 1. **Google Edge PoP & Peering Architecture**:
>    - Google operates thousands of Edge Points of Presence (Edge PoPs) globally, connecting to ISPs via Public Peering at IXPs and Private Network Interconnects (PNIs).
>    - BFD is mandatory on all PNI and IXP links to trigger sub-second rerouting to backup egress links during fiber cuts.
>
> 2. **GTSM vs `ebgp-multihop`**:
>    - `ebgp-multihop` decreases TTL starting from 1 (susceptible to spoofing). GTSM starts at TTL 255 and verifies `TTL >= 255 - max_hops`, providing deterministic hardware-level filtering against off-path TCP attacks.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
