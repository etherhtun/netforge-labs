# 🧪 Lab 04 · MACsec Line-Rate Encryption & Port Security

> ✅ **Validated** on 802.1AE MACsec specification.

**Time:** ~45 minutes · **Tools:** IEEE 802.1AE MACsec, MKA (MACsec Key Agreement)

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/security-lab
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
