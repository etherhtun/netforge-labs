# 🧪 Lab 02 · Inbound & Outbound BGP Traffic Engineering

> ✅ **Validated** on Arista cEOS 4.32.0F.

**Time:** ~45 minutes · **Tools:** Route Maps, AS-PATH Prepending, BGP Communities

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

---
## 🧠 Technology Deep Dive: Steering Traffic Across Dual ISPs

When multihomed to two ISPs, BGP path selection determines how outbound and inbound traffic flows:

### 1. Outbound Traffic Control (`LOCAL_PREF`)
`LOCAL_PREF` is an iBGP-only attribute passed between `wan-edge1` and `wan-edge2`. Higher `LOCAL_PREF` values win:
- Primary ISP A (`198.51.100.2`): `LOCAL_PREF 200` (Preferred)
- Backup ISP B (`203.0.113.2`): `LOCAL_PREF 100`

---

### 2. Inbound Traffic Control (AS-PATH Prepending)
To force external networks to prefer Primary ISP A for inbound traffic, `wan-edge2` prepends its own Autonomous System number multiple times (`65000 65000 65000`) towards Backup ISP B:

```eos
route-map PREPEND-OUT permit 10
   set as-path prepend 65000 65000 65000
```

✅ **DONE when** `show ip route bgp` on external networks prefers Primary ISP A due to shorter AS-PATH length.
