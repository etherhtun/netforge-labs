# 🧪 Lab 03 · Infrastructure ACLs (iACLs) & Core Protection

> ✅ **Validated** on Arista cEOS 4.32.0F.

**Time:** ~45 minutes · **Tools:** Infrastructure ACLs (iACLs)

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/security-lab
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
