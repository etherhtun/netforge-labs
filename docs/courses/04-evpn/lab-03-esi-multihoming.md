# 3️⃣ Lab 03 · ESI All-Active Multihoming (DF Election & Split-Horizon)

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~50 minutes · **Nodes:** 6 (2 Spines, 2 Leafs, 2 Multihomed Hosts)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/evpn-datacenter-lab
      ./run.sh 03          # apply + verify step 03 automatically
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-evpn-datacenter-lab-leaf1 Cli
      leaf1> enable
      leaf1# configure
      ```

---

## 🧠 Zero-to-Hero Technology Deep Dive: EVPN ESI Multihoming Mechanics

### 1. Why ESI Multihoming Replaces MLAG / vPC
Traditional MLAG (Multi-Chassis Link Aggregation) requires a dedicated inter-switch **Peer-Link** and **Keepalive Link** between a pair of switches. This introduces proprietary control planes, limits multihoming to exactly 2 switches, and risks split-brain scenarios if peer-links fail.

**EVPN ESI (Ethernet Segment Identifier) Multihoming (RFC 7432)** eliminates MLAG peer-links entirely! Multiple Leaf switches form an **Active-Active multihomed group** toward a customer server or switch using standard LACP, coordinated purely through BGP EVPN control plane messages!

---

### 2. The Three Pillars of EVPN Multihoming

```
+---------------------------------------------------------------------------------------------------+
| EVPN ESI MULTIHOMING PILLARS                                                                      |
+---------------------------------------------------------------------------------------------------+
| 1. Ethernet Segment Identifier (ESI): 10-byte unique ID assigned to the multihomed interface.   |
| 2. Designated Forwarder (DF) Election (Route Type 4): Prevents duplicate BUM traffic delivery.  |
| 3. Split-Horizon Filtering (Route Type 1): Prevents local loops between multihomed leaves.        |
+---------------------------------------------------------------------------------------------------+
```

#### A. Ethernet Segment Identifier (ESI)
An **ESI** is a 10-byte non-zero value (e.g., `00:11:22:33:44:55:66:77:88:99`) configured on the physical interface or Port-Channel connecting a server to `leaf1` and `leaf2`. Because both leaves share the same ESI, BGP EVPN treats them as a single logical connection.

#### B. Designated Forwarder (DF) Election via EVPN Route Type 4
When BUM (Broadcast, Unknown Unicast, Multicast) traffic arrives from the fabric destined for a multihomed host, BOTH `leaf1` and `leaf2` could potentially forward it down to the server, causing duplicate frames.
- **EVPN Route Type 4 (Ethernet Segment Route)**: `leaf1` and `leaf2` exchange Route Type 4 routes to discover each other on the ESI segment.
- **DF Election**: Using a modulo algorithm (`VLAN ID mod N`), one Leaf is elected **Designated Forwarder (DF)** for VLAN 10 and forwards BUM traffic to the server. The Non-DF Leaf blocks BUM egress.

#### C. Split-Horizon Filtering via EVPN Route Type 1
If `host1` sends a broadcast frame to `leaf1`, `leaf1` encapsulates it in VXLAN and floods it to `leaf2` via Head-End Replication. Without protection, `leaf2` would forward the frame back down its local link to `host1`, creating a loop!
- **EVPN Route Type 1 (Auto-Discovery Route)**: `leaf1` includes an **ESI Label** in its Route Type 1 update.
- When `leaf2` decapsulates the packet and sees its own local ESI label, it drops the packet instead of forwarding it down the ESI interface (**Split-Horizon Filtering**).

---

## Step 1 · ESI Port-Channel Configuration

Configure matching 10-byte ESI values on `leaf1` and `leaf2` Ethernet3 ports.

=== "leaf1"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/04-leaf1-esi.cfg"
    ```

=== "leaf2"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/04-leaf2-esi.cfg"
    ```

---

## Step 2 · Production Verification

Verify ESI status and Designated Forwarder (DF) election on `leaf1`:

```bash
docker exec -i clab-evpn-datacenter-lab-leaf1 Cli -p 15 <<'EOF'
enable
show bgp evpn route-type es
EOF
```

```
BGP routing table information for VRF default
Route type: 4 (Ethernet Segment Route)
   ESI: 00:11:22:33:44:55:66:77:88:99
   Designated Forwarder: 10.255.0.11 (Local)
```

✅ **DONE when** `leaf1` displays Designated Forwarder state for ESI `00:11:22:33:44:55:66:77:88:99`.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
