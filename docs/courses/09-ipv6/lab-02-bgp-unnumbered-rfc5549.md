# 🧪 Lab 02 · BGP Unnumbered (BGP over IPv6 Link-Local RFC 5549)

> ✅ **Validated** on Arista cEOS 4.32.0F.

**Time:** ~45 minutes · **Tools:** BGP Unnumbered, Extended Next Hop (RFC 5549 / RFC 8950)

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/ipv6-lab
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
