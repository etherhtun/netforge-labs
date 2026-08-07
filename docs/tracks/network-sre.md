# 🤖 Site Reliability Engineer (SRE) — Network Track

> 🚀 **Production Reliability & Automated Operations**: Master production incident mitigation, sub-second BFD failover, gNMI real-time streaming telemetry, Prometheus anomaly detection, and automated PyATS health gate checks.

---

## 🎯 Target Roles & Target Companies
- **Target Roles**: Network SRE, Infrastructure SRE, Production Reliability Engineer, Production Operations Lead.
- **Target Employers**: Google, Meta, Apple, AWS, Microsoft, ByteDance, and High-Scale SaaS Platforms.

---

## 🧠 Core Network SRE Engineering Pillars

| SRE Pillar | Key Production Technologies | Engineering Objective |
|---|---|---|
| **Sub-Second Link Failover** | **BFD (Bidirectional Forwarding Detection)** | Sub-second link failure detection & hardware offload |
| **Real-Time Observability** | **gNMI / OpenConfig / Prometheus / Grafana** | High-cardinality time-series metric streaming & alerts |
| **Automated Testing** | **PyATS / Genie Assertions** | Automated pre-change and post-change gate checks |
| **Control Plane Resilience** | **CoPP (Control Plane Policing)** | Protecting switch routing engine CPUs under DDoS floods |
| **Error Budget & SLOs** | **SLO / SLA Budget Management** | Managing failure domains & blast radius containment |

---

## 🧪 Sequential Lab Roadmap

```mermaid
graph TD
    S1["1. BGP Path Failure Isolation<br/>(Phase 1 & Phase 6)"] ==> S2["2. Sub-Second BFD Failover<br/>(Phase 6 Lab 03)"]
    S2 ==> S3["3. Automated PyATS Health Checks<br/>(Phase 5 Lab 02)"]
    S3 ==> S4["4. gNMI Real-Time Telemetry<br/>(Phase 7 Lab 01 & 02)"]
    S4 ==> S5["5. Prometheus & Grafana Alerts<br/>(Phase 7 Lab 03 & 05)"]
    S5 ==> S6["6. CoPP Control Plane Protection<br/>(Phase 8 Lab 01)"]

    classDef sre fill:#6a1b9a,stroke:#ce93d8,color:#ffffff,stroke-width:2px,font-weight:bold;
    class S1,S2,S3,S4,S5,S6 sre;
```

---

## 📁 Executable Local Lab Environment

```bash
# Clone repository & enter Telemetry & Observability lab
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/telemetry-lab

# Deploy gNMI streaming telemetry and Prometheus metrics
./run.sh --all
```
