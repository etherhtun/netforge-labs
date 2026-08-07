# 🧪 Lab 01 · Active/Standby & Active/Active Dual-ISP eBGP

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~40 minutes · **Nodes:** 4 (2 WAN Edge Routers, 2 ISP Routers)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/wan-edge-lab
      ./run.sh 01          # apply + verify step 01 automatically
      ./run.sh --all       # run all steps in order
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-wan-edge-lab-wan-edge1 Cli
      wan-edge1> enable
      wan-edge1# configure
      ```

---

## 🚀 Getting Started & Repository Setup

Before starting this lab, clone the repository (or run `git pull` if already cloned) and navigate to the lab directory:

```bash
# 1. Clone repository (or pull latest changes)
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs

# 2. Enter the WAN Edge lab directory
cd labs/wan-edge-lab
```

---

## 🧠 Technology Deep Dive: Dual-ISP Multihoming Mechanics

In enterprise WAN edge architectures, connecting to a single ISP creates a single point of failure (SPOF). **Dual-ISP eBGP Multihoming** establishes separate eBGP sessions to two independent Autonomous Systems:

```
                      +-------------------+
                      |   PRIMARY ISP     |
                      |   (ASN 65100)     |
                      +---------+---------+
                                |  eBGP
                                |  198.51.100.0/30
                      +---------+---------+
                      |    wan-edge1      |
                      |   (ASN 65000)     |
                      +---------+---------+
                                |  iBGP 10.0.0.0/30
                      +---------+---------+
                      |    wan-edge2      |
                      |   (ASN 65000)     |
                      +---------+---------+
                                |  eBGP
                                |  203.0.113.0/30
                      +---------+---------+
                      |    BACKUP ISP     |
                      |   (ASN 65200)     |
                      +-------------------+
```

---

## Step 1 · Configure eBGP Sessions to Dual ISPs

Configure eBGP sessions on `wan-edge1` (Primary ISP) and `wan-edge2` (Backup ISP).

=== "wan-edge1"

    ```eos
    --8<-- "labs/wan-edge-lab/steps/01-wan-edge1-ebgp.cfg"
    ```

=== "wan-edge2"

    ```eos
    --8<-- "labs/wan-edge-lab/steps/01-wan-edge2-ebgp.cfg"
    ```

=== "isp-primary"

    ```eos
    --8<-- "labs/wan-edge-lab/steps/01-isp-primary-ebgp.cfg"
    ```

=== "isp-backup"

    ```eos
    --8<-- "labs/wan-edge-lab/steps/01-isp-backup-ebgp.cfg"
    ```

---

## Step 2 · Production Verification

Verify eBGP neighbor state on `wan-edge1`:

```bash
docker exec -i clab-wan-edge-lab-wan-edge1 Cli -p 15 <<'EOF'
enable
show bgp summary
EOF
```

```
BGP summary information for VRF default
Router identifier 10.255.0.1, local AS number 65000
Neighbor        V  AS           MsgRcvd   MsgSent  InQ OutQ  Up/Down State   PfxRcd
10.0.0.2        4  65000             15        15    0    0 00:02:10 Estab   1
198.51.100.2    4  65100             15        15    0    0 00:02:10 Estab   1
```

✅ **DONE when** `show bgp summary` outputs `198.51.100.2` (Primary ISP) in `Estab` state.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
