# 🧪 Lab 04 · Stateful NAT64 & DNS64 Translation Mechanics

> ✅ **Validated** on NAT64 / DNS64 specification (RFC 6146).

**Time:** ~45 minutes · **Tools:** Stateful NAT64, DNS64 Synthetic AAAA

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/ipv6-lab
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
