# 🧪 Lab 04 · Stateful NAT64 & DNS64 Translation Mechanics

> ✅ **Validated** on NAT64 / DNS64 specification (RFC 6146).

**Time:** ~45 minutes · **Tools:** Stateful NAT64, DNS64 Synthetic AAAA

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
## 🧠 Technology Deep Dive: NAT64 & DNS64 Translation

IPv6-only endpoints (`2001:db8::100`) cannot directly communicate with legacy IPv4 servers (`192.0.2.50`) because IPv4 and IPv6 packet headers are incompatible.

- **DNS64**: Synthesizes IPv6 `AAAA` records for IPv4-only domains using the Well-Known Prefix (`64:ff9b::/96`).
- **Stateful NAT64**: Translates IPv6 packets with destination `64:ff9b::192.0.2.50` into IPv4 packets with destination `192.0.2.50`.

```eos
ip nat64 prefix 64:ff9b::/96
ip nat64 pool NAT64-POOL 198.51.100.100 198.51.100.110
```

✅ **DONE when** IPv6-only host successfully pings IPv4 service via synthetic `64:ff9b::` prefix.
