# Interview Questions — Phase 2 · BGP-DIA & Internet Edge

These self-test questions target **Google Network Infrastructure Engineer (NIE)** and **Hyperscale Edge System Engineer** technical interview scenarios.

---

## DIA Traffic Engineering & BGP Communities

??? question "How do you force egress traffic to prefer Provider A over Provider B regardless of AS_PATH length?"
    Set **`LOCAL_PREF`** to a higher value (e.g., 150) on inbound route advertisements from Provider A. `LOCAL_PREF` is evaluated at Step 2 of the BGP best-path decision algorithm, overriding `AS_PATH` length (Step 4).

??? question "Why do Standard BGP Communities fail for 4-byte ASNs, and how do Large Communities fix this?"
    Standard BGP communities use 32 bits (`16-bit ASN : 16-bit Value`). If an organization has a 32-bit 4-byte ASN (e.g., Google `AS15169` or `AS195169`), it cannot fit inside the 16-bit ASN field. **Large Communities (RFC 8092)** provide 96 bits (`32-bit Global Admin : 32-bit Action : 32-bit Target`), formatted as three 32-bit integers (`15169:1000:70`).

??? question "What is the difference between Hot-Potato and Cold-Potato routing?"
    **Hot-Potato routing** hands off egress traffic to the nearest external ISP interface as quickly as possible to save internal network bandwidth. **Cold-Potato routing** carries traffic across a private internal backbone (like Google B4) as close to the destination as possible before handing off, maximizing latency control and SLA.

??? question "Scenario: Asymmetric routing across Provider A and B causes stateful firewalls to drop return TCP packets. How do you resolve this?"
    1. **Stateful Session Synchronization**: Cluster stateful firewalls across edge points using high-speed HA synchronization links so all firewall nodes share the TCP session state.
    2. **Ingress Path Alignment**: Tag outbound advertisements to Provider B with BGP Large Communities (`65003:70`) or AS-Path Prepending (`prepend 65001 65001`) to depress Provider B's Local Preference, forcing return traffic through Provider A.
    3. **BGP Session Sharing / ARG**: Implement Asymmetric Routing Groups (ARG) at the edge router layer to route return traffic over an inter-edge iBGP link to the originating firewall.

---

## RPKI & BGP Defensive Security

??? question "What are the three RPKI validation states, and how should an edge router act on them?"
    - **`Valid`**: Prefix and origin AS match a signed ROA object. *Permit with normal/high preference (`LOCAL_PREF 120`).*
    - **`Invalid`**: ROA exists but origin AS or prefix length mismatches. **Drop immediately (`deny`) to prevent BGP hijacks.**
    - **`NotFound`**: No ROA exists in global repositories. *Permit with default preference (`LOCAL_PREF 100`) to avoid dropping legitimate non-RPKI signed Internet routes.*

??? question "Why is `maxLength` critical in RPKI ROAs for preventing prefix de-aggregation hijacks?"
    BGP always prefers the longest match. If a target network advertises `10.0.0.0/16`, an attacker can advertise `10.0.1.0/24` to hijack traffic. By specifying `maxLength 20` in the ROA for `10.0.0.0/16`, any route advertisement more specific than `/20` (like `/24`) is evaluated as **`Invalid`** and dropped by all RPKI-enforcing transit routers.

??? question "Compare Remotely Triggered Blackhole (RTBH) vs BGP Flowspec (RFC 8955) under DDoS attack."
    - **RTBH (RFC 7999 `65535:666`)**: Rewrites next-hop for the target `/32` IP to `Null0` at the ISP edge. Drops **100% of traffic** (both attack and legitimate), sacrificing the victim IP to preserve WAN bandwidth.
    - **BGP Flowspec (RFC 8955)**: Pushes granular 5-tuple ACL filtering rules (e.g. drop UDP port 123 NTP amplification traffic targeting `203.0.113.50`) into transit provider hardware TCAMs, scrubbing attack traffic while keeping legitimate host services operational.

---

## IXP Peering, BFD & GTSM

??? question "Why is BFD preferred over standard BGP hold timers on Internet peering links?"
    Standard BGP hold timers (180s default) take up to 3 minutes to detect a silent link failure. **BFD (Bidirectional Forwarding Detection)** exchanges rapid hardware-offloaded micro-probes (e.g., 300 ms) to detect link or optical degradation in <1 second, triggering instant BGP path convergence.

??? question "How does GTSM (Generalized TTL Security Mechanism, RFC 3682) defend eBGP sessions?"
    GTSM sets outgoing eBGP packet TTL to 255 and enforces `ttl-security hops 1` on incoming packets (requiring `TTL >= 254`). Because intermediate routers decrement TTL by 1 at each hop, an off-path attacker across the Internet cannot inject TCP packets targeting port 179 without the packet being dropped by edge hardware ASICs before reaching the CPU.

??? question "How does an IXP Route Server maintain participant privacy and prevent Next-Hop manipulation?"
    An IXP Route Server strips its own ASN from the `AS_PATH` and enforces `no-next-hop-change`. This allows two peering participants (AS 100 and AS 200) to exchange routes via the Route Server without inserting the RS into the data path or `AS_PATH`, enabling direct peer-to-peer data plane forwarding across the IXP switch fabric.

---

## CGNAT & IPv6 Transition

??? question "What is RFC 6598 Shared Address Space and why is it used for CGNAT?"
    RFC 6598 defines `100.64.0.0/10` specifically for Service Provider Carrier-Grade NAT (CGNAT). It prevents IP address conflicts between customer private LANs (RFC 1918) and ISP internal core routing tables.

??? question "How does Deterministic NAT (Port-Block Allocation) solve logging scale issues?"
    Standard NAT logs every 5-tuple translation individually, generating terabytes of log data per day. Deterministic NAT algorithmically assigns fixed blocks of ports (e.g., 1,024 ports per subscriber), allowing operators to map any public IP + port back to a subscriber using a static mathematical formula ($\text{Port Start} = 1024 + \text{Subscriber Index} \times 1024$) without per-connection logging.

??? question "How does DNS64/NAT64 handle IPv6-only clients connecting to IPv4-only services?"
    When an IPv6 client requests an AAAA record for an IPv4-only host, **DNS64** synthesizes an AAAA record by prefixing the IPv4 address with the `64:ff9b::/96` IPv6 prefix. When the client sends IPv6 packets to that synthesized address, the **NAT64** gateway intercepts the packet, translates the IPv6 header to IPv4, and forwards it to the IPv4 destination.

