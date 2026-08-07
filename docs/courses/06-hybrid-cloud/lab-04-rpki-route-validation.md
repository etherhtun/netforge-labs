# 🧪 Lab 04 · Local RPKI Route Origin Validation (ROV)

> ✅ **Validated** on RPKI / ROA Validation logic.

**Time:** ~45 minutes · **Tools:** RPKI, ROA (Route Origin Authorization)

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/wan-edge-lab
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
