# 🧪 Lab 02 · Integrated Routing & Bridging (Symmetric IRB & Anycast Gateway)

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~50 minutes · **Nodes:** 6 (2 Spines, 2 Leafs, 2 Customer Hosts)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/evpn-datacenter-lab
      ./run.sh 02          # apply + verify step 02 automatically
      ./run.sh --all       # run all steps in order
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-evpn-datacenter-lab-leaf1 Cli
      leaf1> enable
      leaf1# configure
      ```

---

## 🧠 Technology Deep Dive: Symmetric IRB vs. Asymmetric IRB

### 1. The Inter-Subnet Routing Challenge
Pure L2VNI (Lab 01) extends Layer 2 bridging, but when host workloads in different IP subnets (e.g. `10.10.10.0/24` in VLAN 10 and `10.20.20.0/24` in VLAN 20) need to communicate, traffic MUST be routed at Layer 3. 

In EVPN-VXLAN, **Integrated Routing and Bridging (IRB)** handles this at the Leaf layer using two different architectural approaches:

---

### 2. Asymmetric IRB (Legacy / Scale-Constrained)
In Asymmetric IRB:
- The **ingress Leaf routes** the packet from source VLAN to destination VLAN, then **bridges** the packet over the destination L2 VNI.
- **The Catch**: Every Leaf router in the fabric MUST have EVERY VLAN and EVERY L2 VNI configured, even if no local hosts exist on that leaf! This severely limits fabric VLAN scalability.

---

### 3. Symmetric IRB (Hyperscale Production Standard)
In Symmetric IRB:
- **Routing occurs on BOTH the Ingress and Egress Leaf**:
  1. Ingress Leaf routes from source VRF to a shared **Layer 3 VNI (`50001`)**.
  2. The packet travels across the fabric encapsulated in the L3 VNI header (`VNI 50001`).
  3. Egress Leaf receives the packet on L3 VNI `50001` and routes it into the destination tenant VRF.
- **Key Advantage**: Leafs only need to configure the VLANs for locally connected hosts. Scale is limited only by hardware routing table capacity, not VLAN mapping limits!

```
+---------------------------------------------------------------------------------------------------+
| SYMMETRIC IRB PACKET ENCAPSULATION PATH                                                           |
+---------------------------------------------------------------------------------------------------+
| 1. Host1 (VLAN 10) sends frame to local Anycast Gateway (10.10.10.1, MAC 00:1c:73:00:00:01)       |
| 2. Leaf1 routes packet into VRF TENANT-A, looks up destination host IP (10.20.20.20)             |
| 3. Leaf1 encapsulates frame into L3 VNI 50001 (Outer Dst IP: Leaf2 VTEP 10.255.1.12)             |
| 4. Leaf2 decapsulates L3 VNI 50001, routes packet into VRF TENANT-A, forwards to Host2 in VLAN 20  |
+---------------------------------------------------------------------------------------------------+
```

---

### 4. Anycast Virtual Gateway
To support seamless virtual machine and container mobility across leaves without modifying default gateway settings:
- **Identical Virtual IP (`10.10.10.1/24`)** and **Identical Virtual MAC (`00:1c:73:00:00:01`)** are configured on all Leaf switches.
- Hosts ARP for their default gateway and receive the exact same MAC response regardless of which leaf switch they are attached to!

---

## Step 1 · Underlay IP & MP-iBGP EVPN Setup

Ensure OSPF underlay and MP-iBGP EVPN sessions are operational between Spines and Leafs.

=== "spine1"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/01-spine1-underlay.cfg"
    ```

=== "leaf1"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/01-leaf1-underlay.cfg"
    ```

---

## Step 2 · Symmetric IRB & Anycast Gateway Configuration

Configure L2 VNI `10100`, L3 VNI `50001` (VRF `TENANT-A`), Anycast Gateway IP (`10.10.10.1/24`), and Virtual Router MAC (`00:1c:73:00:00:01`).

=== "leaf1 (Symmetric IRB)"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/03-leaf1-vxlan-irb.cfg"
    ```

=== "leaf2 (Symmetric IRB)"

    ```eos
    --8<-- "labs/evpn-datacenter-lab/steps/03-leaf2-vxlan-irb.cfg"
    ```

---

## Step 3 · End-to-End Verification & Route Type 5 Analysis

### 1. Verify EVPN Route Type 5 (L3 Prefix Routes)
Verify that `leaf1` receives L3 VNI `50001` prefix routes from `leaf2`:

```bash
docker exec -i clab-evpn-datacenter-lab-leaf1 Cli -p 15 <<'EOF'
enable
show bgp evpn route-type prefix-segment
EOF
```

### 2. Test Inter-Subnet Routing
Ping host workload across Symmetric IRB fabric:

```bash
docker exec -i clab-evpn-datacenter-lab-host1 Cli -p 15 <<'EOF'
enable
ping 10.10.10.20 repeat 5
EOF
```

✅ **DONE when** `host1` pings `host2` across **Symmetric IRB L3 VNI `50001`**.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
