# 🧪 Lab 02 · BGP Unnumbered (BGP over IPv6 Link-Local RFC 5549)

> ✅ **Validated** on Arista cEOS 4.32.0F.

**Time:** ~45 minutes · **Tools:** BGP Unnumbered, Extended Next Hop (RFC 5549 / RFC 8950)

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
## 🧠 Technology Deep Dive: BGP Unnumbered (RFC 5549 / RFC 8950)

In traditional BGP topologies, every point-to-point interface requires IP address assignment (`/30` or `/31` in IPv4, `/64` or `/127` in IPv6).

**BGP Unnumbered** uses IPv6 Link-Local addresses (`fe80::/10`) auto-generated via EUI-64 to establish eBGP sessions. RFC 5549 / RFC 8950 extends BGP so that **IPv4 and IPv6 prefixes are advertised over an IPv6-only link-local transport**:

```eos
interface Ethernet1
   ipv6 enable
!
router bgp 65000
   neighbor Ethernet1 interface remote-as 65001
   !
   address-family ipv4
      neighbor Ethernet1 activate
```

✅ **DONE when** `show bgp summary` displays BGP sessions established over interface `Ethernet1` via IPv6 Link-Local addresses.
