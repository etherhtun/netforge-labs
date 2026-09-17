# 🧪 Lab 04 · Local RPKI Route Origin Validation (ROV)

> ✅ **Validated** on RPKI / ROA Validation logic.

**Time:** ~45 minutes · **Tools:** RPKI, ROA (Route Origin Authorization)

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
## 🧠 Technology Deep Dive: RPKI Route Origin Validation

BGP route hijacking occurs when an unauthorized Autonomous System advertises prefixes belonging to another organization. **RPKI (Resource Public Key Infrastructure)** uses cryptographically signed ROA objects to validate that the origin AS is authorized to announce the prefix:

- **Valid**: Origin AS matches ROA record $\rightarrow$ Accept route.
- **Invalid**: Origin AS does NOT match ROA record $\rightarrow$ Drop route immediately.
- **NotFound**: No ROA record exists $\rightarrow$ Accept with lower preference.

```eos
router bgp 65000
   rpki cache local-validator
      host 172.20.20.1 port 3323
```

✅ **DONE when** `show bgp rpki status` reports active RPKI validation sessions.
