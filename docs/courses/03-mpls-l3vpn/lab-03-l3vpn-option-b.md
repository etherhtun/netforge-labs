# 🧪 Lab 03 · Inter-AS L3VPN Option B (ASBR MP-eBGP VPNv4 Exchange)

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~55 minutes · **Nodes:** 6 (2 PE Routers, 2 ASBR Routers, 2 P Core Routers across AS 65001 & AS 65002)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/mpls-l3vpn-lab
      ./run.sh 03          # apply + verify step 03 automatically
      ./run.sh --all       # run all steps in order
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-mpls-l3vpn-lab-asbr1 Cli
      asbr1> enable
      asbr1# configure
      ```
      Or push individual step snippets using stdin:
      `docker exec -i clab-mpls-l3vpn-lab-asbr1 Cli -p 15 < steps/03-asbr1-optionb.cfg`

---

## Architecture & Inter-AS Option Comparison

```mermaid
graph LR
    subgraph AS65001["Service Provider AS 65001"]
        PE1["pe1 (PE Router)"] -.-|MP-iBGP VPNv4|-.- ASBR1["asbr1 (ASBR)"]
    end

    subgraph AS65002["Service Provider AS 65002"]
        ASBR2["asbr2 (ASBR)"] -.-|MP-iBGP VPNv4|-.- PE2["pe2 (PE Router)"]
    end

    ASBR1 <===>|Inter-AS MP-eBGP VPNv4<br/>(Label Swapped at ASBR)| ASBR2

    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef asbr fill:#4a148c,stroke:#ba68c8,color:#ffffff,stroke-width:2px,font-weight:bold;

    class PE1,PE2 pe; class ASBR1,ASBR2 asbr;
```

### Inter-AS Options Comparison Matrix

| Option | Handoff Type | Scalability | ASBR State Overhead | Next-Hop & Label Handling |
|---|---|---|---|---|
| **Option A** | Back-to-back VRF sub-interfaces | Low | High (Separate sub-interface + eBGP session per customer VRF) | Standard IPv4 eBGP per VRF |
| **Option B** | Inter-AS MP-eBGP VPNv4 | **High** | **Medium** (Stores VPNv4 routes in BGP table, no VRFs required on ASBR) | **ASBR rewrites Next-Hop & allocates new VPN service label** |
| **Option C** | Multi-hop MP-eBGP + BGP-LU (RFC 3107) | **Hyperscale** | **Low** (ASBR does not process or store VPNv4 routes) | End-to-end BGP Labeled Unicast transport |

---

## Step 1 · ASBR MP-eBGP Session Configuration

On `asbr1` (AS 65001) and `asbr2` (AS 65002), enable MP-eBGP in address-family `vpn-ipv4` and disable Next-Hop filtering.

```eos
! Applied on asbr1 (AS 65001)
router bgp 65001
   neighbor 10.0.12.2 remote-as 65002
   neighbor 10.0.12.2 description "Inter-AS-Option-B-PEER-asbr2"
   !
   address-family vpn-ipv4
      neighbor 10.0.12.2 activate
```

---

## Step 2 · ASBR Label Rewriting & Next-Hop Self

For Option B to function across provider boundaries, the receiving ASBR must re-advertise received VPNv4 routes to its internal MP-iBGP peers with `next-hop-self`. During this re-advertisement, the ASBR allocates a **new inner VPN label** and swaps it in hardware.

```eos
! Applied on asbr1 for internal MP-iBGP peers
router bgp 65001
   neighbor 1.1.1.1 remote-as 65001
   neighbor 1.1.1.1 update-source Loopback0
   !
   address-family vpn-ipv4
      neighbor 1.1.1.1 activate
      neighbor 1.1.1.1 next-hop-self
```

**Verification:**

```bash
docker exec -i clab-mpls-l3vpn-lab-asbr1 Cli -p 15 <<'EOF'
enable
show bgp vpn-ipv4 detail
EOF
```

```
BGP routing table entry for 10.100.2.0/24, Route Distinguisher 65002:100
  Paths: 1 available
  Local
    10.0.12.2 from 10.0.12.2 (10.0.12.2)
      Origin IGP, localpref 100, valid, external, best
      MPLS info:
        in label: 100023
        out label: 24012
```

✅ **DONE when** `asbr1` allocates an `in label` and maps it to an `out label` for the VPNv4 route.

---

## 🧠 Google Network Infra Knowledge Sharing & Protocol Mechanics

> [!NOTE]
> ### 1. Option B Packet Forwarding Stack (3-Label Swap at Inter-AS Boundary)
>
> In Inter-AS Option B, as a packet crosses from AS 65001 to AS 65002:
> 1. Inside AS 65001: Packet travels with `[Transport Label LDP_AS1] [VPN Label L1]`.
> 2. At `asbr1` (ASBR Handoff): `asbr1` pops `LDP_AS1`, swaps `VPN Label L1` $\rightarrow$ `VPN Label L2`, and transmits the packet un-encapsulated by LDP directly across the inter-AS link with `[VPN Label L2]`.
> 3. At `asbr2` (Receiving ASBR): `asbr2` swaps `VPN Label L2` $\rightarrow$ `VPN Label L3`, pushes new transport label `[LDP_AS2]`, and forwards into AS 65002 core.

> [!IMPORTANT]
> ### 2. Security & Carrier Interconnection Best Practices
>
> - **ASBR Route Filtering**: Always apply `prefix-list` and `max-prefix` limits on Inter-AS MP-eBGP sessions to prevent remote provider route table exhaustion attacks.
> - **No VRF Overhead on ASBR**: Unlike Option A (which requires $N$ VRFs for $N$ customers), Option B processes all customer VPNs inside a single global BGP table (`vpn-ipv4`), reducing ASBR RAM consumption by up to 80%!

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
