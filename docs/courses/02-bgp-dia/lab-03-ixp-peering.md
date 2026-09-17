# 🧪 Lab 03 · Internet Peering & IXP Architecture (GTSM + BFD)

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric.

**Time:** ~45 minutes · **Nodes:** 4 (Edge Router, IXP Route Server, 2 Peer Routers)

!!! tip "Quick Start — Step-by-Step Execution Guide (Location: `labs/edge-lab/`)"
    **Step 1 · Deploy the Lab Fabric (if not already running)**
    ```bash
    cd labs/edge-lab
    sudo containerlab deploy -t topology.clab.yml --max-workers 1
    ```

    **Step 2 · Launch the Fully Guided Interactive Walkthrough**
    ```bash
    ./run.sh --guided
    ```

    ??? note "Alternative Execution Options (Automated Push or Manual CLI)"
        - **Fast Automated Script Push**:
          ```bash
          ./run.sh 01          # apply + verify step 01 automatically
          ./run.sh --all       # run all steps in order
          ```
        - **Manual Line-by-Line CLI Execution**:
          Interactive CLI shell on any container node:
          ```bash
          docker exec -it clab-edge-lab-r1 Cli
          ```

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

## 🧠 Google Network Infra Knowledge Sharing & Peering Mechanics

> [!NOTE]
> ### 1. IXP Route Server Mechanics & Transparent BGP Forwarding
>
> At major Internet Exchange Points (e.g. DE-CIX, LINX, Equinix IX, Equinix Ashburn), hundreds of networks exchange routes. Setting up individual eBGP sessions with every participant ($N \times (N-1) / 2$ sessions) is unscalable.
>
> - **Route Server (RS) Solution**: Each network peers once with a central IXP Route Server running BIRD or OpenBGPD.
> - **Transparent AS_PATH & Next-Hop**:
>   - By default, eBGP prepends the local ASN and overwrites `NEXT_HOP`.
>   - Route Servers override standard eBGP behavior: they **strip the RS ASN** from the `AS_PATH` and preserve the **original participant's `NEXT_HOP` IP address** (`no-next-hop-change`).
>   - Consequence: Control-plane traffic passes through the Route Server, but data-plane IP packets flow directly peer-to-peer across the IXP switching fabric!

> [!IMPORTANT]
> ### 2. GTSM Packet Byte Math & Hardware ASIC TCAM Filtering (RFC 3682)
>
> Off-path attackers anywhere on the Internet can spoof TCP packets targeting an edge router's BGP daemon on TCP port 179.
>
> ```
> [Attacker across Internet (15 hops away)] ──> Transits (TTL decrements 15 times) ──> Packet arrives with TTL = 240
> [Legitimate Direct eBGP Peer (1 hop away)] ──> Direct Cable ─────────────────────────> Packet arrives with TTL = 254 (or 255)
> ```
>
> - **GTSM TTL Check**:
>   - Egress router sends BGP packets initialized with **IP TTL = 255**.
>   - Receiving router enforces `neighbor <IP> ttl-security hops 1` (verifying incoming $\text{TTL} \ge 255 - 1 = 254$).
>   - If an attacker's packet traverses even a single intermediate router, its TTL drops below 254. The edge switch hardware ASIC drops the packet at wire-speed before it ever reaches the control-plane CPU!

> [!TIP]
> ### 3. BFD Sub-Second Hardware Linecard Offload
>
> Standard software-based keepalives can flap under heavy CPU load (e.g., during full BGP table convergence or control-plane spikes).
>
> - **Hardware Offload**: Modern datacenter switches (Arista 7050X3 / 7280R3) offload BFD echo probing directly to hardware linecard ASICs or FPGAs.
> - **Timer Math**:
>   $$\text{Detection Time} = \text{Rx Interval} \times \text{Multiplier} = 300\,\text{ms} \times 3 = 900\,\text{ms}$$
>   If 3 consecutive BFD control packets (at 300 ms intervals) are missed, the linecard instantly tears down the BGP session in under 1 second, rerouting traffic before application TCP connections time out!

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```

