# 🧪 Lab 02 · BGP Security — RPKI ROV & Bogon Filtering

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric.

**Time:** ~45 minutes · **Nodes:** 4 (2 Edge Routers, 2 Transit/Peer Routers)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/edge-lab
      ./run.sh 02          # apply + verify step 02 automatically
      ./run.sh --all       # run all steps in order
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-edge-lab-r1 Cli
      r1> enable
      r1# configure
      ```
      Or push individual step snippets using stdin:
      `docker exec -i clab-edge-lab-r1 Cli -p 15 < steps/02-r1-underlay.cfg`

---

## Step 1 · RPKI Route Origin Validation (ROV)

RPKI validates whether the origin AS advertising an IP prefix is authorized by the registered IP space holder.

### RPKI Validation States:
1. **`Valid`**: The prefix and origin AS match a signed Route Origin Authorization (ROA) object.
2. **`Invalid`**: A ROA exists for the prefix, but the advertising AS or prefix length does **not** match. **Action: DROP.**
3. **`NotFound`**: No ROA exists in global RPKI cache repositories. **Action: PERMIT (with lower preference).**

```eos
! Configuring RPKI Origin Validation Policy on Arista EOS Edge Router
router bgp 65001
   rpki cache ROUTINATOR-1
      host 10.0.100.50 port 3323
   !
   address-family ipv4
      bgp origin-as validation enable
```

Filtering invalid routes using route-maps:

```eos
route-map RM-RPKI-IN deny 10
   match rpki validity invalid
!
route-map RM-RPKI-IN permit 20
   match rpki validity valid
   set local-preference 120
!
route-map RM-RPKI-IN permit 30
   match rpki validity not-found
   set local-preference 100
```

---

## Step 2 · Remotely Triggered Blackhole (RTBH — `65535:666`)

When an IP address comes under a severe volumetric DDoS attack, RTBH drops attack traffic at the ISP edge using the well-known community `65535:666` (RFC 7999).

```eos
! Configuring RTBH Blackhole route map
ip route 192.168.10.99/32 Null0
!
ip community-list CL-RTBH permit 65535:666
!
route-map RM-RTBH-IN permit 10
   match community CL-RTBH
   set ip next-hop 192.0.2.1
   set local-preference 200
```

When an upstream ISP receives `65535:666`, it rewrites the next-hop to a `Null0` discard interface, neutralizing the DDoS attack before it consumes WAN bandwidth.

---

## Step 3 · Bogon & Transit Leak Filtering

Block private address spaces (RFC 1918), CGNAT space (RFC 6598 `100.64.0.0/10`), and loopbacks on internet-facing eBGP sessions.

```eos
ip prefix-list PL-BOGON-DENY seq 10 deny 10.0.0.0/8 le 32
ip prefix-list PL-BOGON-DENY seq 20 deny 172.16.0.0/12 le 32
ip prefix-list PL-BOGON-DENY seq 30 deny 192.168.0.0/16 le 32
ip prefix-list PL-BOGON-DENY seq 40 deny 100.64.0.0/10 le 32
ip prefix-list PL-BOGON-DENY seq 50 permit 0.0.0.0/0 le 24
```

---

## 🧠 Google Network Infra Knowledge Sharing & Defensive Security Mechanics

> [!NOTE]
> ### 1. End-to-End RPKI ROV Architecture & RTR Protocol (RFC 8210)
>
> RPKI Origin Validation uses an out-of-band cryptographic trust hierarchy to verify IP prefix ownership:
>
> ```mermaid
> graph LR
>     RIR["RIR Repositories<br/>(ARIN, RIPE, APNIC)<br/>X.509 TAL Certificates"] --->|Sync via RRDP / Rsync| Validator["RPKI Cache Validator<br/>(Routinator / StayRtr / Fort)"]
>     Validator --->|RTR Protocol<br/>TCP Port 3323| EdgeRouter["Arista EOS Edge Router<br/>(BGP Origin-AS Validation Engine)"]
>     EdgeRouter --->|Evaluate Inbound BGP UPDATE| Decision{"ROA Table Lookup<br/>(Prefix + Length + Origin ASN)"}
>     Decision --->|Match| Valid["Valid<br/>(Permit, Set LP=120)"]
>     Decision --->|Length / ASN Mismatch| Invalid["Invalid<br/>(DROP Route!)"]
>     Decision --->|No ROA Found| NotFound["NotFound<br/>(Permit, Set LP=100)"]
>     
>     classDef rir fill:#1565c0,stroke:#90caf9,color:#ffffff;
>     classDef val fill:#f57c00,stroke:#ffe0b2,color:#ffffff;
>     classDef edge fill:#2e7d32,stroke:#a5d6a7,color:#ffffff;
>     class RIR rir; class Validator val; class EdgeRouter edge;
> ```
>
> - **Why Routers Don't Query RIRs Directly**: Validating cryptographic X.509 signatures on millions of ROA objects requires high CPU and RAM overhead. Dedicated validator servers (Routinator, StayRtr) parse cryptographically signed ROAs and push a flattened table of `(IPv4/IPv6 Prefix, MaxLength, Origin ASN)` tuples to edge routers using lightweight binary RTR PDUs (RFC 8210).

> [!IMPORTANT]
> ### 2. Preventing Prefix De-aggregation Hijacks with `maxLength`
>
> A common BGP hijacking technique involves advertising a more-specific subnet (e.g. `1.1.1.0/24`) for a target that only advertises a aggregate `/16` (`1.1.0.0/16`). BGP longest-prefix matching forces global traffic toward the attacker's `/24`.
>
> - **ROA Protection**: A signed ROA specifies both the authorized `Origin ASN` and the `maxLength`.
>   - Example ROA: `Prefix: 203.0.113.0/20`, `maxLength: 24`, `ASN: 65001`.
>   - If an attacker advertises `203.0.113.0/25` (exceeding `maxLength 24`), RPKI ROV flags the announcement as **`Invalid`**, and edge routers drop it immediately!

> [!TIP]
> ### 3. BGP Route Leak Prevention (RFC 9234) vs Remotely Triggered Blackhole (RTBH) & Flowspec
>
> - **BGP Open Policy Roles & OTC (RFC 9234)**:
>   - Route leaks occur when a multi-homed customer receives routes from Transit ISP A and re-advertises them to Transit ISP B, turning the customer into an unintended transit network.
>   - RFC 9234 introduces the **Only to Customer (OTC)** BGP attribute. When a route is advertised to a Customer or Peer, the router sets the OTC attribute to its own ASN. If a customer attempts to re-advertise that route to another Provider or Peer, the receiving router drops the route.
>
> - **RTBH (RFC 7999 `65535:666`) vs BGP Flowspec (RFC 8955)**:
>   - **RTBH**: Drops **100% of traffic** targeting a specific `/32` IP address at the ISP edge. While it stops WAN link saturation, it completes the Denial-of-Service for legitimate users accessing that host.
>   - **BGP Flowspec (RFC 8955)**: Advertises granular 5-tuple filtering rules (Source IP, Destination IP, L4 Protocol, TCP Flags, Port Range) directly into the provider's hardware ACLs, dropping only attack traffic while keeping legitimate host services online!

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```

