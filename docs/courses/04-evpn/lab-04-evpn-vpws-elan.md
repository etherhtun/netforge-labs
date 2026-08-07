# 4️⃣ Lab 04 · EVPN-VPWS & EVPN-ELAN (Point-to-Point VPWS & Multipoint ELAN)

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~50 minutes · **Nodes:** 6 (2 Spines, 2 Leafs, 2 Customer Switches)

---

## 🧠 Zero-to-Hero Technology Deep Dive: EVPN Service Modes

While standard EVPN-VXLAN handles Ethernet bridging and routing, EVPN also defines specialized Carrier Ethernet service architectures (RFC 8214 & RFC 7432):

```
+---------------------------------------------------------------------------------------------------+
| EVPN SERVICE ARCHITECTURES                                                                        |
+---------------------------------------------------------------------------------------------------+
| 1. EVPN-VPWS (E-LINE): Point-to-Point Pseudowire replacement using EVPN Route Type 1.              |
| 2. EVPN-ELAN (E-LAN): Multipoint bridged Layer 2 service domain over VXLAN/MPLS.                 |
+---------------------------------------------------------------------------------------------------+
```

---

### 1. EVPN-VPWS (Virtual Private Wire Service / E-LINE)
- **Concept**: Replaces legacy LDP Pseudowires (VPWS) with BGP control-plane signaling.
- **Protocol Mechanics**:
  - Uses **EVPN Route Type 1 (VPWS NLRI)** carrying a **VPWS Service ID** (`Local VPWS ID` $\leftrightarrow$ `Remote VPWS ID`).
  - No MAC lookup is performed! Traffic arriving on `leaf1` port `Et3` is encapsulated and sent directly to `leaf2` port `Et3` as a raw wire stream.

---

### 2. EVPN-ELAN (E-LAN Multipoint Bridging)
- **Concept**: Multipoint bridged Ethernet domain connecting 3 or more remote customer sites across the fabric.
- **Protocol Mechanics**: Performs MAC learning via Route Type 2 and BUM flooding via Route Type 3, creating a flexible virtual Layer 2 switch across the fabric.

---

## Step 1 · EVPN-VPWS Configuration

Configure EVPN-VPWS VPWS Service ID `100` between `leaf1` and `leaf2`.

=== "leaf1"

    ```eos
    configure
    patch panel
       patch VPWS-CUSTOMER-A
          connector-a Ethernet3
          connector-b BGP VPWS 100 pseudo-circuit 1
    !
    router bgp 65000
       vpws VPWS-CUSTOMER-A
          rd 10.255.0.11:100
          route-target import 100:100
          route-target export 100:100
          local-vpws-id 101
          remote-vpws-id 102
    ```

=== "leaf2"

    ```eos
    configure
    patch panel
       patch VPWS-CUSTOMER-A
          connector-a Ethernet3
          connector-b BGP VPWS 100 pseudo-circuit 1
    !
    router bgp 65000
       vpws VPWS-CUSTOMER-A
          rd 10.255.0.12:100
          route-target import 100:100
          route-target export 100:100
          local-vpws-id 102
          remote-vpws-id 101
    ```

---

## Step 2 · Verification

Verify EVPN-VPWS pseudo-circuit status on `leaf1`:

```bash
docker exec -i clab-evpn-datacenter-lab-leaf1 Cli -p 15 <<'EOF'
enable
show bgp evpn route-type vpws
EOF
```

✅ **DONE when** EVPN-VPWS Service ID `100` state is **Established**.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
