# 🧪 Lab 01 · Active/Standby & Active/Active Dual-ISP eBGP

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~40 minutes · **Nodes:** 4 (2 WAN Edge Routers, 2 ISP Routers)

!!! tip "Quick Start — Step-by-Step Execution Guide (Location: `labs/wan-edge-lab/`)"
    **Step 1 · Deploy the Lab Fabric (if not already running)**
    ```bash
    cd labs/wan-edge-lab
    sudo containerlab deploy -t topology.clab.yml --max-workers 1
    ```

    **Step 2 · Launch the Fully Guided Interactive Walkthrough**
    ```bash
    ./run.sh --guided
    ```

    ??? note "Alternative Execution Options (Automated Push or Manual CLI)"
        - **Fast Automated Script Push**:
          ```bash
          ./run.sh 01          # apply + verify step 01 automatically
          ./run.sh --all       # run all steps in order
          ```
        - **Manual Line-by-Line CLI Execution**:
          Interactive CLI shell on any container node:
          ```bash
          docker exec -it clab-wan-edge-lab-wan-edge1 Cli
          ```

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
