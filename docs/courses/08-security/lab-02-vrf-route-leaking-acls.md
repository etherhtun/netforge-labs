# 🧪 Lab 02 · VRF Microsegmentation & Inter-VRF Route Leaking

> ✅ **Validated** on Arista cEOS 4.32.0F.

**Time:** ~45 minutes · **Tools:** VRF Isolation, Route Maps, IP Access Lists

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/security-lab
```

---

## 🧠 Technology Deep Dive: VRF Microsegmentation

Multi-tenant data centers isolate different customer departments (`VRF-TENANT-A`, `VRF-TENANT-B`) into separate routing tables. When tenant workloads require controlled access to a shared management service (`VRF-SHARED-SERVICES`), inter-VRF route leaking is configured with strict IP access-lists:

```eos
vrf instance VRF-TENANT-A
!
ip route vrf VRF-TENANT-A 10.100.0.0/16 vrf VRF-SHARED-SERVICES
```

✅ **DONE when** `show ip route vrf VRF-TENANT-A` displays leaked shared service subnets while blocking lateral traffic to `VRF-TENANT-B`.
