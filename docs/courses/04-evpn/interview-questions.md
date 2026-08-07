# Phase 4 · BGP EVPN & Datacenter Self-Test Interview Questions

Test your knowledge with these Google-style Datacenter Infrastructure & EVPN interview questions.

---

### Q1: What are BGP EVPN Route Types 1, 2, 3, 4, and 5?
**Answer:**
- **Route Type 1 (Ethernet Auto-Discovery)**: Advertises Ethernet Segment reachability; used for fast failover (Mass Withdraw) and ESI Split-Horizon label distribution.
- **Route Type 2 (MAC/IP Advertisement)**: Advertises host MAC addresses and optional IPv4/IPv6 host routes for ARP suppression and host reachability.
- **Route Type 3 (Inclusive Multicast Ethernet Tag - IMET)**: Establishes headend replication tunnels for BUM (Broadcast, Unknown Unicast, Multicast) traffic.
- **Route Type 4 (Ethernet Segment Route)**: Enables PE discovery and Designated Forwarder (DF) election for All-Active ESI multihoming.
- **Route Type 5 (IP Prefix Route)**: Advertises subnet prefixes (e.g. `10.100.0.0/16`) for inter-subnet routing across VRFs.

---

### Q2: What is the difference between Symmetric IRB and Asymmetric IRB?
**Answer:**
- **Asymmetric IRB**: Ingress VTEP routes traffic from source VNI into destination VNI locally, then bridges traffic across destination VNI to egress VTEP. Egress VTEP requires every tenant VNI configured.
- **Symmetric IRB**: Ingress VTEP routes traffic into a shared **L3 VRF VNI**, encapsulates, and forwards to egress VTEP. Egress VTEP receives packet on L3 VNI and routes into destination VNI. Scale far better in multi-tenant fabrics.

---

### Q3: How does EVPN handle loop prevention in an All-Active Multihoming scenario?
**Answer:**
EVPN uses **Split-Horizon Filtering** via EVPN Route Type 1 (Auto-Discovery Route). When a Leaf node encapsulates BUM traffic from a multihomed host, it attaches an **ESI Label**. When the peer multihomed Leaf receives this packet, it checks the ESI label. Because it matches its own local ESI for that segment, it drops the packet toward the host, preventing the loop.

---

### Q4: In EVPN All-Active Multihoming, how is BUM traffic duplicate delivery prevented?
**Answer:**
Using **Designated Forwarder (DF) Election** (EVPN Route Type 4). All leaves connected to the same ESI exchange Route Type 4 messages. They run a modulo algorithm (e.g., `VLAN ID mod N`) to elect a single Designated Forwarder for each VLAN. Only the DF is allowed to forward BUM traffic down to the multihomed CE device. Non-DF nodes block BUM egress to that segment.

---

### Q5: What is MAC Mobility in EVPN, and how does it solve virtual machine migration loops?
**Answer:**
When a VM (MAC address) moves from Leaf1 to Leaf2, Leaf2 learns the MAC locally and advertises a new EVPN Route Type 2. To ensure all other nodes know this is a legitimate move and not a network loop/flap, EVPN uses a **MAC Mobility Sequence Number** extended community. 
- Leaf1 originally advertised the MAC with Sequence `0`.
- Leaf2 advertises the moved MAC with Sequence `1`. 
- When Leaf1 receives Sequence `1`, it realizes the host has moved, withdraws its own Route Type 2, and flushes the MAC. If the MAC moves back and forth rapidly, a MAC duplication/flap dampening mechanism is triggered.

---

### Q6: Why is ARP Suppression important in EVPN fabrics?
**Answer:**
In a large subnet stretched across a VXLAN fabric, ARP broadcasts (BUM traffic) consume significant fabric bandwidth and CPU. EVPN **Proxy ARP / ARP Suppression** allows the ingress Leaf to intercept the ARP request. If the Leaf already knows the target's MAC address from the EVPN BGP database (Route Type 2), it replies directly to the host locally, suppressing the broadcast from ever entering the VXLAN fabric.
