# 🧪 Lab 02 · Inbound & Outbound BGP Traffic Engineering

> ✅ **Validated** on Arista cEOS 4.32.0F.

**Time:** ~45 minutes · **Tools:** Route Maps, AS-PATH Prepending, BGP Communities

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/wan-edge-lab
```

---

## 🧠 Technology Deep Dive: Steering Traffic Across Dual ISPs

When multihomed to two ISPs, BGP path selection determines how outbound and inbound traffic flows:

### 1. Outbound Traffic Control (`LOCAL_PREF`)
`LOCAL_PREF` is an iBGP-only attribute passed between `wan-edge1` and `wan-edge2`. Higher `LOCAL_PREF` values win:
- Primary ISP A (`198.51.100.2`): `LOCAL_PREF 200` (Preferred)
- Backup ISP B (`203.0.113.2`): `LOCAL_PREF 100`

---

### 2. Inbound Traffic Control (AS-PATH Prepending)
To force external networks to prefer Primary ISP A for inbound traffic, `wan-edge2` prepends its own Autonomous System number multiple times (`65000 65000 65000`) towards Backup ISP B:

```eos
route-map PREPEND-OUT permit 10
   set as-path prepend 65000 65000 65000
```

✅ **DONE when** `show ip route bgp` on external networks prefers Primary ISP A due to shorter AS-PATH length.
