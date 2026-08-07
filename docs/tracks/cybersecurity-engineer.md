# 🔒 Network Security Architect Track

> 🚀 **Future-Proof Career Track**: Master Control Plane Protection (CoPP), Zero-Trust VRF Microsegmentation, Infrastructure ACLs (iACLs), IEEE 802.1AE MACsec Line-Rate Encryption, and RPKI Route Origin Validation.

---

## 🎯 Target Roles & Industry Demand
- **Roles**: Network Security Architect, Principal SecOps Engineer, Datacenter Security Lead, Infrastructure Security Architect.
- **Target Companies**: Financial Institutions (JPMorgan, Goldman Sachs), Defense & Government Contractors, Hyperscalers (Google, Meta, AWS), and Global Enterprises.

---

## 🧠 Core Production Security Requirements

| Security Domain | Production Risk / Attack Vector | Engineering Solution & Protocol |
|---|---|---|
| **Control Plane Protection** | SYN Floods & DDoS targeting switch CPU | **Control Plane Policing (CoPP)** rate-limiting at switch ASIC level |
| **Datacenter Segmentation** | East-West Lateral Threat Movement | **Zero-Trust VRF Microsegmentation** + Inter-VRF Route Leaking ACLs |
| **Core Router Protection** | External IP Scanning & Transit Spoofing | **Infrastructure Access Control Lists (iACLs)** protecting loopbacks |
| **Physical Link Security** | Man-in-the-Middle (MitM) Fiber Tapping | **IEEE 802.1AE MACsec (AES-256-GCM)** line-rate hardware encryption |
| **BGP Edge Security** | BGP Route Hijacking & Prefix Leaks | **RPKI Route Origin Validation (ROV)** & ROA Validator daemons |

---

## 🧪 Sequential Hands-On Lab Roadmap

```mermaid
graph TD
    S1["1. RPKI BGP Security<br/>(Phase 2)"] ==> S2["2. Control Plane Policing CoPP<br/>(Phase 8 Lab 01)"]
    S2 ==> S3["3. VRF Microsegmentation<br/>(Phase 8 Lab 02)"]
    S3 ==> S4["4. Infrastructure ACLs iACLs<br/>(Phase 8 Lab 03)"]
    S4 ==> S5["5. MACsec Line-Rate Encryption<br/>(Phase 8 Lab 04)"]
    S5 ==> S6["6. NAT64/DNS64 Perimeter Control<br/>(Phase 9 Lab 04)"]

    classDef sec fill:#0d47a1,stroke:#64b5f6,color:#ffffff,stroke-width:2px,font-weight:bold;
    class S1,S2,S3,S4,S5,S6 sec;
```

---

## 📁 Executable Lab Environment

All security mechanisms are 100% containerized and executable locally:

```bash
# Clone repository & enter security lab
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/security-lab

# Run all security gate checks live on OrbStack cEOS nodes
./run.sh --all
```

---

## 🎯 Network Security Architect Interview Drills

### ❓ Question 1: How does CoPP protect the switch CPU during a 10Mpps SYN flood?
**Answer:**
CoPP applies `class-map` classifiers and `policy-map` hardware rate-limiters at the switch ASIC ingress pipeline **before** packets are punted to the CPU. Unspecified or high-rate traffic exceeding the committed rate (`police pps 1000`) is dropped in hardware, allowing critical BGP and OSPF keepalives to reach the routing daemon without CPU starvation.

### ❓ Question 2: Why is MACsec preferred over IPsec for interconnecting data center switches?
**Answer:**
IPsec operates at Layer 3 and requires software fragmentation/reassembly overhead, adding microsecond latency and reducing throughput. **MACsec (IEEE 802.1AE)** operates at Layer 2 directly on the Ethernet physical layer, encrypting the entire payload (including VLAN tags) at 100G/400G line rate inside switch ASICs with zero packet latency penalty.
