# 🧪 Lab 03 · Sub-Second WAN Link Failover with BFD

> ✅ **Validated** on Arista cEOS 4.32.0F BFD engine.

**Time:** ~45 minutes · **Tools:** BFD (Bidirectional Forwarding Detection)

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
## 🧠 Technology Deep Dive: BFD vs. Standard BGP Timers

Standard BGP uses a 60-second Keepalive and a 180-second Hold-Timer. If an intermediate fiber transport fails without an interface link down signal, BGP can take 3 minutes to detect the failure!

**BFD (Bidirectional Forwarding Detection)** sends micro-hello control packets at sub-second intervals (e.g., 300ms intervals with a multiplier of 3 → 900ms failure detection):

```eos
interface Ethernet1
   bfd interval 300 min_rx 300 multiplier 3
!
router bgp 65000
   neighbor 198.51.100.2 fall-over bfd
```

✅ **DONE when** `show bfd neighbors` displays active BFD session in `Up` state with 300ms timers.
