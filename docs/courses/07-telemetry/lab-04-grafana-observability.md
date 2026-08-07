# 🧪 Lab 04 · Real-Time Visual Grafana Network Dashboards

> ✅ **Validated** on Grafana 10.3.

**Time:** ~45 minutes · **Tools:** Grafana Dashboard

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/telemetry-lab
```

---

## 🧠 Technology Deep Dive: Network Observability Dashboards

**Grafana** connects to Prometheus time-series data to render real-time dashboards of network throughput, BGP neighbor states, and interface errors:

- **Interface Throughput (bits/sec)**:
  `rate(openconfig_interfaces_interface_state_counters_in_octets[1m]) * 8`
- **BGP Peer State (Established = 1)**:
  `openconfig_bgp_neighbor_state_session_state == 1`

Access the local dashboard at `http://localhost:3000`.

✅ **DONE when** Grafana renders real-time throughput graphs for cEOS interfaces.
