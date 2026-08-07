# 🎯 Hyperscale System Design & Google Technical Interview Drill

> 🚀 **Senior & Staff Network Infrastructure Engineering Masterclass**: Scenario-based system design drills, failure domain analysis, and protocol trade-off questions asked by **Google, Meta, Apple, and Amazon**.

---

## 🏛️ Module 1 · 5-Stage Clos (Fat-Tree) Fabric Scaling

### Question 1: How do hyperscale networks scale beyond a standard 2-tier Spine-Leaf topology?
**Answer:**
A standard 2-tier Spine-Leaf topology (e.g. 4 Spines $\times$ 8 Leafs) is limited by the fixed port-density of the Spine switches (e.g. 32-port or 64-port ASIC chips). When all Spine ports are consumed, you cannot add more Leaf switches without oversubscribing the fabric.

Hyperscalers (Google Jupiter, Meta F4/F16) solve this by building a **5-Stage Clos (Fat-Tree)** network:
1. **ToR (Top of Rack / Leaf)**: Connects servers.
2. **Fabric Switch (Spine / Pod Switch)**: Aggregates ToRs within a single Pod (Cluster).
3. **Super-Spine (Spine / Core Switch)**: Interconnects independent Pods at the building/datacenter level.

```
+-----------------------------------------------------------------------+
|                       SUPER-SPINE PLANE (Stage 3)                      |
|       [SuperSpine-1]    [SuperSpine-2]    [SuperSpine-3]    [SuperSpine-4] |
+---------------+-----------------+-----------------+-------------------+
                |                 |                 |
+---------------+-----------------+-----------------+-------------------+
|                        POD 1 (Stage 1 & 2)                             |
|       [Spine-11]        [Spine-12]        [Spine-13]        [Spine-14]   |
|            |                 |                 |                 |    |
|       [Leaf-101]        [Leaf-102]        [Leaf-103]        [Leaf-104]   |
+-----------------------------------------------------------------------+
```

---

## 🧠 Module 2 · BGP Architecture: eBGP (RFC 7938) vs. iBGP + RRs

### Question 2: Why do hyperscalers prefer eBGP over iBGP in data center CLOS fabrics?
**Answer:**

| Parameter | eBGP Data Center Design (RFC 7938) | iBGP Data Center Design |
|---|---|---|
| **Loop Prevention** | Simple `AS-PATH` prepending & `AS-PATH` filtering | Requires Full Mesh or Route Reflectors (`cluster-id`) |
| **Path Selection** | Shortest `AS-PATH` + BGP ECMP across all paths | Complex `LOCAL_PREF` & IGP metric tie-breakers |
| **Blast Radius** | BGP session flap isolations remain local to peer ASN | Route Reflector flaps propagate updates fabric-wide |
| **ASN Allocation** | Private 2-Byte (`64512-65534`) or 4-Byte ASNs | Single AS Number fabric-wide |

---

## ⚡ Module 3 · Sub-Second Convergence & Micro-Loop Avoidance

### Question 3: How do you achieve sub-50ms failover without core state in Segment Routing?
**Answer:**
Using **Ti-LFA (Topology-Independent Loop-Free Alternate)** in SR-MPLS / SRv6:
1. **Pre-computed Backup Path**: The local router pre-computes an explicit Segment Routing SID label stack targeting the Post-Convergence $P$-node and $Q$-node **before** any link failure occurs.
2. **Sub-50ms Hardware Switchover**: Upon physical link drop or BFD signal, the ingress ASIC immediately swaps the forwarding pointer to the pre-programmed Ti-LFA label stack without waiting for IGP convergence.
3. **Zero Micro-Loops**: Because the backup path uses explicit Segment SIDs, traffic is forced along the post-convergence path, completely avoiding transient IGP micro-loops.

---

## 🔒 Module 4 · EVPN ESI All-Active Multihoming vs. Legacy MLAG

### Question 4: How does EVPN ESI Multihoming prevent Layer 2 loops without an inter-switch Peer-Link?
**Answer:**
1. **EVPN Designated Forwarder (DF) Election (Route Type 4)**: Peering leaves elect a DF per VNI using a hash algorithm. Only the DF forwards BUM (Broadcast, Unknown Unicast, Multicast) traffic onto the multihomed ESI link.
2. **Split-Horizon Filtering (Local Bias)**: When a leaf receives BUM traffic from the VXLAN overlay sent by another multihomed leaf, it inspects the ESI label. If the egress interface belongs to the same ESI, the leaf **drops the packet locally** to prevent looping back to the host.
3. **MAC Aliasing (Route Type 1)**: Non-DF leaves announce Auto-Discovery Route Type 1 per ESI, enabling remote VTEPs to perform 50/50 ECMP load balancing across both multihomed switches for unicast traffic.

---

## 📊 Module 5 · NetDevOps, gNMI Telemetry & Control Plane Security

### Question 5: How does gNMI Streaming Telemetry outperform legacy SNMP during production outages?
**Answer:**
- **Push vs. Pull**: SNMP polls devices every 300 seconds over UDP, missing micro-burst link drops. gNMI streams real-time updates over HTTP/2 gRPC `Subscribe` RPCs with sub-second resolution.
- **Data Modeling**: SNMP relies on vendor-specific MIB OID trees (`1.3.6.1.2...`). gNMI uses structured, human-readable **OpenConfig YANG schemas** (`openconfig-interfaces:interfaces/interface/state/counters`).
- **Control Plane Policing (CoPP)**: CoPP rate-limits CPU traffic at the switch ASIC level so that high-rate control plane probes or DDoS floods cannot crash the BGP/OSPF routing engine.
