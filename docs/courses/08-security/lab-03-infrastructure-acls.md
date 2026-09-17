# 🧪 Lab 03 · Infrastructure ACLs (iACLs) & Core Protection

> ✅ **Validated** on Arista cEOS 4.32.0F.

**Time:** ~45 minutes · **Tools:** Infrastructure ACLs (iACLs)

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
## 🧠 Technology Deep Dive: Infrastructure Protection ACLs

**Infrastructure Access Control Lists (iACLs)** protect core router loopback addresses (`10.255.0.0/16`) and point-to-point transit interfaces (`10.0.0.0/16`) from unauthorized external scanning and spoofing:

```eos
ip access-list ACL-INFRASTRUCTURE-PROTECT
   10 permit ospf 10.0.0.0/16 10.0.0.0/16
   20 permit tcp 172.20.20.0/24 10.255.0.0/16 eq ssh
   30 deny ip any 10.255.0.0/16 log
   40 permit ip any any
!
interface Ethernet1
   ip access-group ACL-INFRASTRUCTURE-PROTECT in
```

✅ **DONE when** `show ip access-lists ACL-INFRASTRUCTURE-PROTECT` logs unauthorized access drops targeting loopback IP blocks.
