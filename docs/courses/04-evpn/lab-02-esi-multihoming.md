# 🧪 Lab 02 · EVPN ESI All-Active Multihoming & Fast Convergence

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~55 minutes · **Nodes:** 6 (2 Spines, 2 Leaf VTEPs, 2 Multi-homed Hosts)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/evpn-datacenter-lab
      ./run.sh 04          # apply + verify step 04 automatically
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-evpn-datacenter-lab-leaf1 Cli
      leaf1> enable
      leaf1# configure
      ```

---

## ESI All-Active Multihoming Architecture

```mermaid
graph TD
    subgraph Spines["Spine Layer (BGP EVPN Route Reflectors)"]
        SP1["spine1"] --- SP2["spine2"]
    end

    subgraph Leafs["EVPN ESI Multi-Homing VTEP Pair"]
        LF1["leaf1 (VTEP 1)<br/>ESI: 0001:0001:0001:0001:0001"]
        LF2["leaf2 (VTEP 2)<br/>ESI: 0001:0001:0001:0001:0001"]
    end

    subgraph DualHomedHost["Dual-Homed Server (LACP Port-Channel)"]
        H1["host1 (LACP Active Bonding)"]
    end

    SP1 <===> LF1
    SP1 <===> LF2
    SP2 <===> LF1
    SP2 <===> LF2

    LF1 <===>|Port-Channel1 (ESI 1)| H1
    LF2 <===>|Port-Channel1 (ESI 1)| H1

    classDef spine fill:#0d47a1,stroke:#64b5f6,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef leaf fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef host fill:#e65100,stroke:#ffb74d,color:#ffffff,stroke-width:2px,font-weight:bold;

    class SP1,SP2 spine; class LF1,LF2 leaf; class H1 host;
```

---

## Step 1 · Ethernet Segment Identifier (ESI) Configuration

Configure an identical 10-byte **Ethernet Segment Identifier (ESI)** (`0001:0001:0001:0001:0001`) and LACP System ID on both `leaf1` and `leaf2` facing `host1`.

```eos
! Applied on leaf1 & leaf2
interface Port-Channel1
   switchport access vlan 10
   evpn ethernet-segment
      identifier 0001:0001:0001:0001:0001
      lacp system-id 0001.0001.0001
   rt-delegation
!
interface Ethernet3
   channel-group 1 mode active
```

---

## Step 2 · BGP EVPN Route Type 1 & Type 4 Verification

Inspect the BGP EVPN table for **Route Type 4 (Designated Forwarder Election)** and **Route Type 1 (Ethernet Auto-Discovery)**.

```bash
docker exec -i clab-evpn-datacenter-lab-leaf1 Cli -p 15 <<'EOF'
enable
show bgp evpn route-type ethernet-segment
EOF
```

```
BGP routing table entry for evpn ESI 0001:0001:0001:0001:0001
  Paths: 2 available
  Local
    10.255.0.12 from 10.255.0.12 (10.255.0.12)
      Origin IGP, metric 0, localpref 100, valid, internal
      EVPN ES Flags: Single-Active: No, DF Election: Winner
```

✅ **DONE when** `leaf1` and `leaf2` discover each other's ESI via Route Type 4 and perform Designated Forwarder (DF) election cleanly.

---

## 🧠 Google Network Infra Knowledge Sharing & ESI Protocol Mechanics

> [!NOTE]
> ### 1. ESI Split Horizon Filtering (Local Bias / ESI Label)
>
> In an All-Active ESI multihomed topology, when `leaf1` floods a BUM (Broadcast, Unknown Unicast, Multicast) packet into the VXLAN fabric, `leaf2` receives it.
> - **Split Horizon Rule**: `leaf2` MUST NOT forward the BUM packet back out its local link to `host1`, which would cause a duplicate packet or loop!
> - **Local Bias Filter**: Arista/Cisco switches use the ingress source VTEP IP or ESI Split-Horizon label to drop frames originating from the same ESI domain.

> [!IMPORTANT]
> ### 2. Fast Failover via Route Type 1 (Mass Withdraw)
>
> If the link between `leaf1` and `host1` fails, `leaf1` does NOT need to withdraw thousands of MAC addresses one by one. It sends a **single BGP EVPN Route Type 1 Auto-Discovery (AD) per-ES Mass Withdraw message**, instantly diverting all incoming traffic to `leaf2` in $< 50\,\text{ms}$!
