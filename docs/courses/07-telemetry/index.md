# 📊 Phase 7 · Streaming Telemetry & Observability

> 🚀 **100% Local & Self-Contained Observability Masterclass**: From gNMI gRPC protobuf streams and OpenConfig YANG paths to Prometheus time-series metric collection and real-time Grafana dashboards.

---

## 🏛️ Course Architecture & Telemetry Roadmap

Traditional network monitoring relies on polling device metrics via SNMP (`UDP 161`), which is slow, CPU-intensive, and unencrypted. Phase 7 teaches you how to build a **100% local, real-time streaming telemetry stack** running entirely on containerlab with zero cloud dependencies:

```
Phase 7 · Streaming Telemetry & Observability
├── 🧪 Lab 01 · Enabling gNMI & OpenConfig YANG Data Models on cEOS
├── 🧪 Lab 02 · Querying Live Telemetry via pygnmi & Python
├── 🧪 Lab 03 · Streaming Telemetry Collectors & Prometheus Metrics
├── 🧪 Lab 04 · Real-Time Visual Grafana Network Dashboards
└── 🧪 Lab 05 · Automated Telemetry Alerting & Anomaly Detection
```

---

## 🧠 Why Streaming Telemetry (gNMI) Replaces Legacy SNMP

| Legacy SNMP Polling (`UDP 161`) | Modern gNMI Streaming Telemetry (`TCP 6030`) |
|---|---|
| Pull-based periodic polling (e.g. every 5 min) | **Push-based real-time streaming** (sub-second updates) |
| CPU-heavy SNMP agent MIB tree traversal | **Lightweight Google Protocol Buffers (protobuf)** |
| Unencrypted UDP transmission | **Encrypted HTTP/2 TLS Transport** |
| Proprietary MIB OID numbers (`1.3.6.1.2.1.2.2.1...`) | **Human-Readable OpenConfig YANG Paths** |
