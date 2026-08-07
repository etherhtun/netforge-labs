# 🧪 Lab 03 · Streaming Telemetry Collectors & Prometheus Metrics

> ✅ **Validated** on Prometheus 2.50.

**Time:** ~45 minutes · **Tools:** Prometheus, gNMI Exporter

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/telemetry-lab
```

---

## 🧠 Technology Deep Dive: Time-Series Data Collection

**Prometheus** stores time-series metric data identified by metric names and key-value pairs (labels). The gNMI Exporter subscribes to gNMI streams from cEOS nodes and exposes them on `http://localhost:9090/metrics` for Prometheus scraping:

```yaml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: 'ceos-gnmi'
    static_configs:
      - targets: ['172.20.20.41:6030', '172.20.20.43:6030']
```

✅ **DONE when** Prometheus status targets page (`http://localhost:9090/targets`) shows all cEOS nodes in `UP` state.
