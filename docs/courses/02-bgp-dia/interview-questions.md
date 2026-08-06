# Interview Questions — Phase 2 · BGP-DIA & Internet Edge

These self-test questions target **Google Network Infrastructure Engineer (NIE)** and **Hyperscale Edge System Engineer** technical interview scenarios.

---

## DIA Traffic Engineering & BGP Communities

??? question "How do you force egress traffic to prefer Provider A over Provider B regardless of AS_PATH length?"
    Set **`LOCAL_PREF`** to a higher value (e.g., 150) on inbound route advertisements from Provider A. `LOCAL_PREF` is evaluated at Step 2 of the BGP best-path decision algorithm, overriding `AS_PATH` length (Step 4).

??? question "Why do Standard BGP Communities fail for 4-byte ASNs, and how do Large Communities fix this?"
    Standard BGP communities use 32 bits (`16-bit ASN : 16-bit Value`). If an organization has a 32-bit 4-byte ASN (e.g., Google `AS15169` or `AS195169`), it cannot fit inside the 16-bit ASN field. **Large Communities (RFC 8092)** provide 96 bits (`32-bit Global Admin : 32-bit Action : 32-bit Target`).

??? question "What is the difference between Hot-Potato and Cold-Potato routing?"
    **Hot-Potato routing** hands off egress traffic to the nearest external ISP interface as quickly as possible to save internal network bandwidth. **Cold-Potato routing** carries traffic across a private internal backbone (like Google B4) as close to the destination as possible before handing off, maximizing latency control and SLA.

---

## RPKI & BGP Defensive Security

??? question "What are the three RPKI validation states, and how should an edge router act on them?"
    - **`Valid`**: Prefix and origin AS match a signed ROA object. *Permit with normal/high preference.*
    - **`Invalid`**: ROA exists but origin AS or prefix length mismatches. **Drop immediately to prevent BGP hijacks.**
    - **`NotFound`**: No ROA exists. *Permit with normal/default preference.*

??? question "How does Remotely Triggered Blackhole (RTBH) work using community 65535:666?"
    When a target IP undergoes a severe DDoS attack, the victim network advertises the `/32` prefix with community `65535:666` (RFC 7999) to its upstream ISP. The ISP matches the community and rewrites the next-hop to a `Null0` discard interface, dropping attack traffic at the ISP edge.

---

## IXP Peering, BFD & GTSM

??? question "Why is BFD preferred over standard BGP hold timers on Internet peering links?"
    Standard BGP hold timers (180s default) take up to 3 minutes to detect a silent link failure. **BFD (Bidirectional Forwarding Detection)** exchanges rapid micro-probes (e.g., 300 ms) to detect link or optical degradation in under a second, triggering instant BGP path convergence.

??? question "How does GTSM (Generalized TTL Security Mechanism) defend eBGP sessions?"
    GTSM sets eBGP outgoing TTL to 255 and enforces `ttl-security hops 1` on incoming packets (requiring `TTL >= 254`). Because intermediate routers decrement TTL, an off-path attacker across the Internet cannot inject TCP SYN packets targeting port 179 without the packet being dropped in hardware.

---

## CGNAT & IPv6 Transition

??? question "What is RFC 6598 Shared Address Space and why is it used for CGNAT?"
    RFC 6598 defines `100.64.0.0/10` specifically for Service Provider Carrier-Grade NAT (CGNAT). It prevents IP address conflicts between customer private LANs (RFC 1918) and ISP internal routing tables.

??? question "How does Deterministic NAT (Port-Block Allocation) solve logging scale issues?"
    Standard NAT logs every 5-tuple translation individually, generating terabytes of log data per day. Deterministic NAT algorithmically assigns fixed blocks of ports (e.g., 1,024 ports per subscriber), allowing operators to map any public IP + port back to a subscriber using a static mathematical formula without per-connection logging.
