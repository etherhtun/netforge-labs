# 🧪 Lab 04 · MACsec Line-Rate Encryption & Port Security

> ✅ **Validated** on 802.1AE MACsec specification.

**Time:** ~45 minutes · **Tools:** IEEE 802.1AE MACsec, MKA (MACsec Key Agreement)

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
## 🧠 Technology Deep Dive: IEEE 802.1AE MACsec Mechanics

**MACsec (Media Access Control Security)** operates at Layer 2 (Ethernet) to provide line-rate point-to-point encryption, data integrity, and replay protection across physical fiber links. Unlike IPsec which operates at Layer 3, MACsec encrypts the entire Ethernet payload including VLAN tags:

```
+-------------------+-------------------+-------------------+-------------------+
|  MACsec Header    |  Encrypted 802.1Q | Encrypted IP      | ICV Integrity     |
|  (SecTAG)         |  VLAN Tag         | Payload           | Check Value       |
+-------------------+-------------------+-------------------+-------------------+
```

```eos
macsec profile MACSEC-PROFILE-DC
   cipher aes256-gcm
   key-server priority 16
!
interface Ethernet1
   macsec profile MACSEC-PROFILE-DC
```

✅ **DONE when** `show macsec status` displays active 802.1AE AES-256-GCM hardware encryption sessions.
