# 🧪 Lab 05 · MPLS L2VPN (VPWS Pseudowire & VPLS)

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~50 minutes · **Nodes:** 4 (2 PE Routers, 1 P Core Router, 2 Customer L2 Switches)

!!! tip "Quick Start — Step-by-Step Execution Guide (Location: `labs/mpls-l3vpn-lab/`)"
    **Step 1 · Deploy the Lab Fabric (if not already running)**
    ```bash
    cd labs/mpls-l3vpn-lab
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
          docker exec -it clab-mpls-l3vpn-lab-pe1 Cli
          ```

---

## L2VPN Topology & Service Models

```mermaid
graph LR
    subgraph SiteA["Customer Site A (L2 Domain)"]
        CE1["ce1 (Cust L2 Switch)<br/>VLAN 10"]
    end

    subgraph CoreProvider["Service Provider MPLS Backbone (AS 65000)"]
        PE1["pe1 (PE Router)<br/>2.2.2.2/32"] <===>|OSPF + LDP| P1["p1 (P Core)<br/>1.1.1.1/32"]
        P1 <===>|OSPF + LDP| PE2["pe2 (PE Router)<br/>3.3.3.3/32"]
        PE1 -.-|Targeted LDP Pseudowire (VC ID 100)| PE2
    end

    subgraph SiteB["Customer Site B (L2 Domain)"]
        CE2["ce2 (Cust L2 Switch)<br/>VLAN 10"]
    end

    CE1 <===>|Untagged / Dot1q| PE1
    PE2 <===>|Untagged / Dot1q| CE2

    classDef cust fill:#e65100,stroke:#ffb74d,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef p fill:#0d47a1,stroke:#64b5f6,color:#ffffff,stroke-width:2px,font-weight:bold;

    class CE1,CE2 cust; class PE1,PE2 pe; class P1 p;
```

### L2VPN Service Types Comparison

| L2VPN Service | RFC Standard | Topology | Control Plane | Data Plane Framing |
|---|---|---|---|---|
| **VPWS (Pseudowire / EoMPLS)** | RFC 4664 / RFC 4447 | Point-to-Point (E-LINE) | Targeted LDP (tLDP) | L2 Ethernet over MPLS |
| **VPLS** | RFC 4761 (BGP) / RFC 4762 (LDP) | Point-to-Multipoint (E-LAN) | BGP / tLDP + MAC Learning | MPLS Pseudowire Mesh + Split Horizon |
| **EVPN-VPWS** | RFC 8214 | Point-to-Point (E-LINE) | BGP EVPN (AFI 25 / SAFI 70) | VXLAN or MPLS Encapsulation |
| **EVPN-ELAN** | RFC 7432 | Point-to-Multipoint (E-LAN) | BGP EVPN (RT-2 MAC/IP, RT-3 IMET) | VXLAN or MPLS Encapsulation |

---

## Step 1 · Point-to-Point VPWS Pseudowire Configuration (LDP)

On `pe1`, map interface `Ethernet2` to a **Targeted LDP Pseudowire** connecting to `pe2` (`3.3.3.3`) with Virtual Circuit ID `100`.

```eos
! Applied on pe1 (Arista cEOS)
patch panel
   patch CUST-A-PW
      connector 1 interface Ethernet2
      connector 2 pseudowire bgp vpws CUST-A pseudowire PW1
!
mpls ldp
   router-id 2.2.2.2
   transport-address interface Loopback0
   interface Ethernet1
   no shutdown
```

Alternative static / tLDP pseudowire interface binding on Arista EOS:

```eos
! Interface Pseudowire cross-connect configuration
interface Ethernet2
   no switchport
   pseudowire-connection PW-CE1-CE2
      neighbor 3.3.3.3 pseudowire-id 100
```

---

## Step 2 · Verification of L2VPN Pseudowire State

Verify that the Pseudowire Virtual Circuit (VC) is `Up` and exchanging inner L2 labels.

```bash
docker exec -i clab-mpls-l3vpn-lab-pe1 Cli -p 15 <<'EOF'
enable
show mpls pseudowire
EOF
```

```
Pseudowire status: 1 total, 1 up, 0 down
Peer ID     VC ID   Type       Local Label  Remote Label  Status
3.3.3.3     100     Ethernet   100201       200302        Up
```

✅ **DONE when** Pseudowire status shows `Up` with established VC ID 100.

---

## 🧠 Google Network Infra Knowledge Sharing & L2VPN Mechanics

> [!NOTE]
> ### 1. Anatomy of an MPLS L2VPN Packet (PW Control Word & Control Protocol)
>
> An MPLS L2VPN packet carries:
>
> ```
> [ L2 Transport Header ] [ Outer MPLS Transport Label (LDP) ] [ Inner Pseudowire Label (tLDP/BGP) ] [ Control Word (Optional) ] [ Original Customer L2 Frame ]
> ```
>
> - **Control Word (CW)**: A 4-byte header inserted between the inner PW label and the customer Layer 2 Ethernet payload to prevent out-of-order packet delivery and maintain sequence numbering across ECMP paths.

> [!IMPORTANT]
> ### 2. VPLS Split-Horizon Loop Prevention Rule
>
> In **VPLS (Virtual Private LAN Service)**, PEs form a full mesh of pseudowires. To prevent Layer 2 loops without Running Spanning Tree Protocol across the provider core:
> - **Split Horizon Rule**: A frame received over an ingress pseudowire from one PE must **NEVER** be re-forwarded out over another pseudowire to a third PE. It can only be forwarded to local customer-facing interfaces!

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
