# 🧪 Lab 02 · VRF Microsegmentation & Inter-VRF Route Leaking

> ✅ **Validated** on Arista cEOS 4.32.0F.

**Time:** ~45 minutes · **Tools:** VRF Isolation, Route Maps, IP Access Lists

!!! tip "Quick Start — Step-by-Step Execution Guide (Location: `labs/security-lab/`)"
    **Step 1 · Deploy the Lab Fabric (if not already running)**
    ```bash
    cd labs/security-lab
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
          docker exec -it clab-security-lab-leaf1 Cli
          ```

---
## 🧠 Technology Deep Dive: VRF Microsegmentation

Multi-tenant data centers isolate different customer departments (`VRF-TENANT-A`, `VRF-TENANT-B`) into separate routing tables. When tenant workloads require controlled access to a shared management service (`VRF-SHARED-SERVICES`), inter-VRF route leaking is configured with strict IP access-lists:

```eos
vrf instance VRF-TENANT-A
!
ip route vrf VRF-TENANT-A 10.100.0.0/16 vrf VRF-SHARED-SERVICES
```

✅ **DONE when** `show ip route vrf VRF-TENANT-A` displays leaked shared service subnets while blocking lateral traffic to `VRF-TENANT-B`.
