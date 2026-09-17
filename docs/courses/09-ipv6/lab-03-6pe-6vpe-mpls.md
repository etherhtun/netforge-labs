# 🧪 Lab 03 · 6PE & 6VPE (IPv6 over MPLS Backbones RFC 4659)

> ✅ **Validated** on Arista cEOS 4.32.0F.

**Time:** ~45 minutes · **Tools:** 6PE, 6VPE, MP-BGP Label Exchange

!!! tip "Quick Start — Step-by-Step Execution Guide (Location: `labs/ipv6-lab/`)"
    **Step 1 · Deploy the Lab Fabric (if not already running)**
    ```bash
    cd labs/ipv6-lab
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
          docker exec -it clab-ipv6-lab-leaf1-v6 Cli
          ```

---
## 🧠 Technology Deep Dive: 6PE & 6VPE Mechanics

Upgrading a core service provider MPLS network to native IPv6 is expensive and complex. 

- **6PE (IPv6 Provider Edge)**: Allows Provider Edge (PE) routers to transport IPv6 global prefixes over an IPv4-only MPLS core by binding an MPLS label to the IPv6 prefix via MP-BGP (`AFI 2 / SAFI 1`).
- **6VPE**: Extends 6PE to provide multi-tenant IPv6 L3VPN isolation (`AFI 2 / SAFI 128`).

```eos
router bgp 65000
   address-family ipv6
      neighbor 10.255.0.2 activate
      neighbor 10.255.0.2 send-community standard extended
```

✅ **DONE when** `show bgp ipv6 unicast` displays 6PE 2-label stacks (`Transport Label` + `IPv6 Service Label`).
