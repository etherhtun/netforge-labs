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
