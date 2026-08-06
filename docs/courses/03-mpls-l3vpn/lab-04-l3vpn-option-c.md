# 🧪 Lab 04 · Inter-AS L3VPN Option C (BGP-LU RFC 3107 & Multi-Hop MP-eBGP)

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric.

**Time:** ~60 minutes · **Nodes:** 6 (2 PE Routers, 2 ASBR Routers, 2 P Core Routers across AS 65001 & AS 65002)

**Inter-AS L3VPN Option C** is the most scalable hyperscale architecture for interconnecting massive global networks. ASBRs do **not** process, store, or rewrite customer VPNv4 routes. Instead, ASBRs exchange PE Loopback reachability with labels via **BGP Labeled Unicast (BGP-LU RFC 3107 / RFC 8277)**, while PE routers establish end-to-end **multi-hop MP-eBGP** sessions directly with each other!

---

## Hyperscale Architecture & BGP-LU Flow

```mermaid
graph LR
    subgraph AS65001["Service Provider AS 65001"]
        PE1["pe1 (PE)<br/>Loopback: 2.2.2.2"] --- ASBR1["asbr1 (ASBR)"]
    end

    subgraph AS65002["Service Provider AS 65002"]
        ASBR2["asbr2 (ASBR)"] --- PE2["pe2 (PE)<br/>Loopback: 3.3.3.3"]
    end

    ASBR1 <===>|BGP Labeled Unicast (RFC 3107)<br/>Exchanges 2.2.2.2/32 & 3.3.3.3/32 + Labels| ASBR2
    PE1 <.................. Multi-hop MP-eBGP VPNv4 (Direct PE-to-PE) ..................> PE2

    classDef pe fill:#e8f5e9,stroke:#2e7d32,color:#1b5e20,stroke-width:2px;
    classDef asbr fill:#fff3e0,stroke:#e65100,color:#e65100,stroke-width:2px;

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
docker exec -i clab-ceos-mpls-scratch-asbr1 Cli -p 15 <<'EOF'
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
