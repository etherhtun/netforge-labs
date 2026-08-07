# 🧪 Lab 05 · Automated Telemetry Alerting & Anomaly Detection

> ✅ **Validated** on Prometheus Alertmanager.

**Time:** ~45 minutes · **Tools:** Alertmanager

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/telemetry-lab
```

---

## 🧠 Technology Deep Dive: Automated Network Alerting

Prometheus Alertmanager evaluates streaming telemetry rules every 5 seconds. If an interface drops or a BGP neighbor flaps, an alert fires instantly:

```yaml
groups:
  - name: network_alerts
    rules:
      - alert: BGPNeighborDown
        expr: openconfig_bgp_neighbor_state_session_state != 1
        for: 10s
        labels:
          severity: critical
        annotations:
          summary: "BGP Session Down on {{ $labels.instance }}"
```

✅ **DONE when** shutting down interface `Ethernet1` triggers an instant `BGPNeighborDown` firing alert.
