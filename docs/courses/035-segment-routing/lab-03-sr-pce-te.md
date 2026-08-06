# 🧪 Lab 03 · SR-PCE Centralized Traffic Engineering & BGP Color Steering

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric.

**Time:** ~60 minutes · **Nodes:** 5 (2 PE Routers, 2 P Core Routers, 1 SR-PCE Controller)

In hyperscale networks (like Google's B4 and Meta's Express Backbone), central **Path Computation Elements (SR-PCE)** dynamically compute optimal low-latency or high-bandwidth paths across the global WAN. Headend PE routers map application traffic onto explicit Segment Routing policies using **BGP Color Extended Communities**.

---

## Centralized SR-PCE Architecture

```mermaid
graph TD
    PCE["Central SR-PCE Controller<br/>(Calculates SLA Paths)"]
    
    subgraph WANBackbone["Segment Routing WAN Backbone"]
        PE1["pe1 (Headend PE)"] <===>|PCEP (RFC 5440) / BGP-SRTE| PCE
        PE1 --- P1["p1 (Low-Latency Path)"]
        PE1 --- P2["p2 (High-Bandwidth Path)"]
        P1 --- PE2["pe2 (Tailend PE)"]
        P2 --- PE2
    end

    classDef pce fill:#fff3e0,stroke:#e65100,color:#e65100,stroke-width:2px;
    classDef pe fill:#e8f5e9,stroke:#2e7d32,color:#1b5e20,stroke-width:2px;

    class PCE pce; class PE1,PE2 pe;
```

---

## Step 1 · BGP Color Extended Community Mapping

Define an explicit Segment Routing Policy matching **Color 100** (Low-Latency Path $\le 10\,\text{ms}$) and **Color 200** (Bulk High-Bandwidth Path).

```eos
! Applied on pe1 (Headend PE)
router bgp 65000
   address-family ipv4
      route-map RM-COLOR-STEER permit 10
         set extcommunity color 100
!
segment-routing
   traffic-engineering
      policy POLICY-LOW-LATENCY
         binding-sid 24001
         color 100 endpoint 3.3.3.3
         segment-list SL-LOW-LATENCY
            index 10 label 16002
            index 20 label 16003
```

---

## Step 2 · Verification of SR-TE Binding SID Steering

Verify that traffic matching BGP Color 100 is directed into the SR-TE Policy stack.

```bash
docker exec -i clab-ceos-sr-pe1 Cli -p 15 <<'EOF'
enable
show segment-routing traffic-engineering policy
EOF
```

```
SR-TE Policy: POLICY-LOW-LATENCY
  Color: 100, Endpoint: 3.3.3.3
  Binding SID: 24001
  Status: Active
  Segment List: SL-LOW-LATENCY [ 16002, 16003 ]
  Tunnel Statistics: Packets 41209, Bytes 4203318
```

✅ **DONE when** `SR-TE Policy` is `Active` and steering traffic matched by BGP Color 100.

---

## 🧠 Google Network Infra Knowledge Sharing & SR-TE Mechanics

> [!NOTE]
> ### 1. BGP-SRTE (RFC 9256) & PCEP Protocol (RFC 5440)
>
> - **PCEP (Path Computation Element Communication Protocol)**: Headend routers delegate path computation to an external SDN controller over TCP port 4189.
> - **BGP-SRTE**: The SDN controller advertises computed SR policies directly into headend routers using BGP address-family `srte` (AFI 1 / SAFI 73).

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
