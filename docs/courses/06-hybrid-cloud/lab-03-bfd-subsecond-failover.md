# 🧪 Lab 03 · Sub-Second WAN Link Failover with BFD

> ✅ **Validated** on Arista cEOS 4.32.0F BFD engine.

**Time:** ~45 minutes · **Tools:** BFD (Bidirectional Forwarding Detection)

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/wan-edge-lab
```

---

## 🧠 Technology Deep Dive: BFD vs. Standard BGP Timers

Standard BGP uses a 60-second Keepalive and a 180-second Hold-Timer. If an intermediate fiber transport fails without an interface link down signal, BGP can take 3 minutes to detect the failure!

**BFD (Bidirectional Forwarding Detection)** sends micro-hello control packets at sub-second intervals (e.g., 300ms intervals with a multiplier of 3 $\rightarrow$ 900ms failure detection):

```eos
interface Ethernet1
   bfd interval 300 min_rx 300 multiplier 3
!
router bgp 65000
   neighbor 198.51.100.2 fall-over bfd
```

✅ **DONE when** `show bfd neighbors` displays active BFD session in `Up` state with 300ms timers.
