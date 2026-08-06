# 6 · EVPN VXLAN Packet Walk & Forwarding Mechanics

Understanding how packets are encapsulated, routed, and decapsulated as they move across a VXLAN-EVPN fabric is **one of the most critical topics in Datacenter System Design interviews**.

---

## 1. Intra-Subnet L2 Bridging Packet Walk (Same VNI 10100)

```mermaid
sequenceDiagram
    autonumber
    participant H1 as host1 (10.10.10.10, MAC H1)
    participant L1 as leaf1 (Ingress VTEP 10.255.1.11)
    participant Spine as spine1 (IP Underlay)
    participant L2 as leaf2 (Egress VTEP 10.255.1.12)
    participant H2 as host2 (10.10.10.20, MAC H2)

    H1->>L1: Native L2 Ethernet Frame (Src: MAC_H1, Dst: MAC_H2)
    Note over L1: 1. Looks up MAC_H2 in L2 VNI 10100 table<br/>2. Finds Remote VTEP IP: 10.255.1.12<br/>3. Encapsulates in VXLAN VNI 10100
    L1->>Spine: VXLAN Packet [Outer IP: 10.255.1.11 -> 10.255.1.12] [UDP 4789] [VNI 10100] [Inner Frame]
    Note over Spine: Performs Underlay IP ECMP Routing (Outer IP Lookup)
    Spine->>L2: VXLAN Packet [Outer IP: 10.255.1.11 -> 10.255.1.12] [VNI 10100]
    Note over L2: 1. Decapsulates VXLAN Header (VNI 10100)<br/>2. Looks up Dst MAC_H2 in Local VLAN 10<br/>3. Forwards frame out Access Port Et3
    L2->>H2: Native L2 Ethernet Frame (Src: MAC_H1, Dst: MAC_H2)
```

---

## 2. Inter-Subnet Symmetric IRB Packet Walk (VNI 10100 $\rightarrow$ L3VNI 50001 $\rightarrow$ VNI 10200)

In **Symmetric Integrated Routing and Bridging (IRB)**, routing occurs at **both the ingress leaf and egress leaf**:

```mermaid
sequenceDiagram
    autonumber
    participant H1 as host1 (10.10.10.10, VLAN 10)
    participant L1 as leaf1 (Ingress VTEP)
    participant L2 as leaf2 (Egress VTEP)
    participant H3 as host3 (10.10.20.30, VLAN 20)

    H1->>L1: Frame Dst MAC: Anycast Gateway MAC (00:1c:73:00:00:01)
    Note over L1: 1. Ingress Routing: Routes from Subnet 10.10.10.0/24 to 10.10.20.0/24<br/>2. Replaces Src MAC with Leaf1 Router MAC, Dst MAC with Leaf2 Router MAC<br/>3. Encapsulates inside L3 VRF VNI 50001
    L1->>L2: VXLAN Packet [Outer Dst IP: 10.255.1.12] [L3 VNI 50001] [Router MACs] [IP Payload]
    Note over L2: 1. Receives on L3 VNI 50001<br/>2. Egress Routing: Routes into VRF TENANT-A / VLAN 20<br/>3. Resolves Dst Host3 MAC via EVPN Type 2 table
    L2->>H3: Native Frame (Src MAC: Anycast Gateway MAC, Dst MAC: MAC_H3)
```

### Why Symmetric IRB Scales Best
- **Equal Work Distribution**: Routing is split symmetrically between ingress and egress leafs.
- **Minimal VNI State**: Egress leafs only need to carry the VNIs and VLANs for local hosts attached to them, drastically reducing hardware TCAM memory usage!
