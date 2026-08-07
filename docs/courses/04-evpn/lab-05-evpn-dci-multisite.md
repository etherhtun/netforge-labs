# 5️⃣ Lab 05 · VXLAN-EVPN DCI & Multi-Site (Border Gateway VTEPs)

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~50 minutes · **Nodes:** 8 (4 Spines/BGWs, 4 Leafs across 2 Datacenter Sites)

---

## 🧠 Zero-to-Hero Technology Deep Dive: EVPN Multi-Site DCI Architecture

Connecting multiple geographically dispersed data centers (Data Center Interconnect / DCI) requires scaling EVPN beyond a single IP underlay domain:

```
+---------------------------------------------------------------------------------------------------+
| EVPN MULTI-SITE DCI ARCHITECTURE                                                                  |
+---------------------------------------------------------------------------------------------------+
| 1. Border Gateway (BGW) VTEPs: Act as control-plane and data-plane anchors between sites.         |
| 2. Overlay Index & Path Decoupling: Hides internal leaf VTEPs behind the Border Gateway.           |
| 3. Distributed Anycast Gateway Across Sites: Enables live VM migration between DC1 and DC2.      |
+---------------------------------------------------------------------------------------------------+
```

---

### 1. Border Gateway (BGW) VTEP Mechanics
- **Internal Fabric**: Leaf VTEPs run BGP EVPN peering to local Spines/BGWs.
- **Inter-Site WAN**: Border Gateways (`bgw1` in DC1 $\leftrightarrow$ `bgw2` in DC2) peer over eBGP EVPN (AFI 25 / SAFI 70).
- **NLRI Re-Origination**: Border Gateways rewrite the BGP Next-Hop on all EVPN Route Types (2, 3, 5) to their local Border VTEP IP, preventing internal VTEP IPs from leaking into the WAN.

---

## Step 1 · Border Gateway (BGW) Configuration

Configure Multi-Site Border Gateway on `bgw1` (DC1) and `bgw2` (DC2).

=== "bgw1 (DC1 Border Gateway)"

    ```eos
    configure
    vxlan multi-site
       border-gateway ebgp
       local-vtep-ip 10.255.1.100
    !
    router bgp 65001
       neighbor 192.168.100.2 remote-as 65002
       !
       address-family evpn
          neighbor 192.168.100.2 activate
          neighbor 192.168.100.2 domain remote
    ```

=== "bgw2 (DC2 Border Gateway)"

    ```eos
    configure
    vxlan multi-site
       border-gateway ebgp
       local-vtep-ip 10.255.2.100
    !
    router bgp 65002
       neighbor 192.168.100.1 remote-as 65001
       !
       address-family evpn
          neighbor 192.168.100.1 activate
          neighbor 192.168.100.1 domain remote
    ```

---

## Step 2 · Multi-Site Verification

Verify Inter-Site EVPN peering status on `bgw1`:

```bash
docker exec -i clab-evpn-datacenter-lab-spine1 Cli -p 15 <<'EOF'
enable
show bgp evpn summary
EOF
```

✅ **DONE when** inter-site eBGP EVPN session between `bgw1` and `bgw2` shows **Established**.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
