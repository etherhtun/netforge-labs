# 🌐 Phase 4 · VXLAN-EVPN Datacenter Fabrics

> 🚀 **Production Engineering Masterclass**: From first-principles overlay concepts to enterprise-grade CLOS fabrics, Symmetric IRB, ESI All-Active Multihoming, and Multi-Site DCI.

---

## 🏛️ Course Architecture & Production Roadmap

Phase 4 guides you through **5 progressive hands-on lab modules**. Each lab builds upon the previous, moving from pure Layer 2 VXLAN extension up to multi-site datacenter interconnects:

```
Phase 4 · VXLAN-EVPN Datacenter Fabrics
├── 🧪 Lab 01 · Pure L2VNI (Bridging, BUM Head-End Replication & EVPN RT2/3)
├── 🧪 Lab 02 · Integrated Routing & Bridging (Symmetric IRB & Anycast Gateway)
├── 🧪 Lab 03 · ESI All-Active Multihoming (DF Election & Split-Horizon)
├── 🧪 Lab 04 · EVPN-VPWS & EVPN-ELAN (Point-to-Point VPWS & Multipoint ELAN)
└── 🧪 Lab 05 · VXLAN-EVPN DCI & Multi-Site (Border Gateway VTEPs)
```

---

## 📚 What You Will Master

### 1. Zero-Knowledge Foundations
- **Why VXLAN-EVPN?**: Replacing legacy Spanning Tree (STP) and proprietary MLAG/vPC with open-standard 5-stage CLOS Spine-Leaf fabrics.
- **50-Byte Header Encapsulation**: Outer Ethernet + Outer IP + UDP 4789 + 24-bit VNI + Inner Payload.
- **MTU 9214 Jumbo Frame Standard**: Preventing fragmentation across transport links.

### 2. Deep Control Plane Mechanics (BGP EVPN AFI 25 / SAFI 70)
- **Route Type 1 (Auto-Discovery)**: ESI multihoming, mass withdraw, and Split-Horizon loop filtering.
- **Route Type 2 (MAC/IP Advertisement)**: Control-plane MAC learning and L2/L3 host prefix advertising.
- **Route Type 3 (Inclusive Multicast / IMET)**: Dynamic VTEP discovery for Head-End Replication (HER) of BUM traffic.
- **Route Type 4 (Ethernet Segment)**: Automatic Designated Forwarder (DF) election on ESI segments.
- **Route Type 5 (IP Prefix Route)**: Inter-subnet VRF prefix routing.

### 3. Production Deployment Best Practices
- **Anycast Virtual Gateway Standard**: Identical Virtual IP (`10.10.10.1/24`) and Virtual MAC (`00:1c:73:00:00:01`) across all Leafs.
- **Symmetric IRB Architecture**: Dual-routing on ingress and egress Leafs via L3 VNI (`50001`) for clean multi-tenancy.
- **ESI All-Active Multihoming**: Active-Active server connectivity without MLAG peer-links.
