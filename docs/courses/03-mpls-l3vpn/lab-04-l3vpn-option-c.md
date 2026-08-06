# 🧪 Lab 04 · Inter-AS L3VPN Option C (BGP-LU RFC 3107 & Multi-Hop MP-eBGP)

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~60 minutes · **Nodes:** 6 (2 PE Routers, 2 ASBR Routers, 2 P Core Routers across AS 65001 & AS 65002)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/mpls-l3vpn-lab
      ./run.sh 04          # apply + verify step 04 automatically
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
      `docker exec -i clab-mpls-l3vpn-lab-asbr1 Cli -p 15 < steps/04-asbr1-optionc.cfg`

---

## Hyperscale Architecture & BGP-LU Flow

```mermaid
graph LR
    subgraph AS65001["Service Provider AS 65001"]
        PE1["pe1 (PE Router)<br/>Loopback: 2.2.2.2"] --- ASBR1["asbr1 (ASBR)"]
    end

    subgraph AS65002["Service Provider AS 65002"]
        ASBR2["asbr2 (ASBR)"] --- PE2["pe2 (PE Router)<br/>Loopback: 3.3.3.3"]
    end

    ASBR1 <===>|BGP Labeled Unicast (RFC 3107)<br/>Exchanges 2.2.2.2/32 & 3.3.3.3/32 + Labels| ASBR2
    PE1 <.................. Multi-hop MP-eBGP VPNv4 (Direct PE-to-PE) ..................> PE2

    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef asbr fill:#4a148c,stroke:#ba68c8,color:#ffffff,stroke-width:2px,font-weight:bold;

    class PE1,PE2 pe; class ASBR1,ASBR2 asbr;
```

---

## Step 1 · BGP Labeled Unicast (BGP-LU RFC 3107 / 8277)

On ASBRs (`asbr1` and `asbr2`), enable BGP Labeled Unicast in address-family `ipv4 labeled-unicast` to distribute MPLS labels for PE Loopbacks (`2.2.2.2/32` and `3.3.3.3/32`) across the inter-AS boundary.

```eos
! Applied on asbr1 (AS 65001)
router bgp 65001
   neighbor 10.0.12.2 remote-as 65002
   neighbor 10.0.12.2 description "BGP-LU-InterAS-asbr2"
   !
   address-family ipv4
      neighbor 10.0.12.2 activate
   address-family ipv4 labeled-unicast
      neighbor 10.0.12.2 activate
```

**Verification:**

```bash
docker exec -i clab-mpls-l3vpn-lab-asbr1 Cli -p 15 <<'EOF'
enable
show ip bgp labeled-unicast
EOF
```

```
Network            Next Hop         In Label   Out Label
*> 3.3.3.3/32      10.0.12.2        100105     200401
```

✅ **DONE when** `3.3.3.3/32` appears in `show ip bgp labeled-unicast` with valid `In Label` and `Out Label`.

---

## Step 2 · Multi-Hop MP-eBGP VPNv4 Session Between PEs

With BGP-LU providing end-to-end labeled reachability between `pe1` (`2.2.2.2`) and `pe2` (`3.3.3.3`), configure a direct **multi-hop MP-eBGP** session between the PEs.

```eos
! Applied on pe1 (AS 65001) targeting pe2 (AS 65002)
router bgp 65001
   neighbor 3.3.3.3 remote-as 65002
   neighbor 3.3.3.3 ebgp-multihop 10
   neighbor 3.3.3.3 update-source Loopback0
   !
   address-family vpn-ipv4
      neighbor 3.3.3.3 activate
```

**Data Plane Packet Stack (Three-Label Stack):**

```
[ Outer AS Transport Label (LDP) ] [ Middle Inter-AS Label (BGP-LU) ] [ Inner VPN Service Label (VPNv4) ] [ Customer Packet ]
```

---

## 🧠 Google Network Infra Knowledge Sharing & Hyperscale Engineering

> [!NOTE]
> ### 1. Why Hyperscalers (Google / AWS / Meta) Prefer Option C
>
> 1. **Zero Customer VPN State on ASBRs**: ASBRs carry zero customer VRFs and zero customer VPNv4 routes. They only carry BGP-LU routes for PE loopbacks (~10,000 PEs instead of 10,000,000 VPN routes).
> 2. **End-to-End Encryption & Performance**: Customer traffic is encapsulated at `pe1` and decapsulated at `pe2`. Intermediate ASBRs act as pure label-switching forwarding nodes (P routers).
> 3. **Seamless Integration with Segment Routing (SR-MPLS / SRv6)**: Option C BGP-LU integrates natively with Segment Routing Egress Peer Engineering (SR-EPE) and SDN controllers.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
