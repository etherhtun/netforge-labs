# 📋 Technical Program Manager (TPM) & System Design Track

> 🚀 **Hyperscale Architecture & Program Leadership**: Master 5-Stage Clos fabric scaling math, eBGP vs. iBGP trade-offs, blast radius containment, SLA / convergence budget calculations, and vendor RFPs.

---

## 🎯 Target Roles & Target Companies
- **Target Roles**: Technical Program Manager (TPM), Infrastructure Program Lead, Network Solutions Architect, Infrastructure Delivery Director.
- **Target Employers**: Google, Meta, Apple, AWS, Microsoft, Large Enterprise Financials, and Cloud Consultancies.

---

## 🧠 Core TPM Engineering & Leadership Pillars

| Program Domain | Key Architectural Decisions | Leadership & Program Function |
|---|---|---|
| **Fabric Scaling Math** | **5-Stage Clos vs 2-Tier Spine-Leaf** | ASIC port-density calculations & pod expansion planning |
| **Routing Protocol Selection** | **eBGP RFC 7938 vs iBGP + RRs** | Blast radius containment & BGP ASN allocation models |
| **Convergence SLAs** | **Sub-50ms Ti-LFA vs IGP Timers** | Establishing production availability & error budgets |
| **Telemetry vs Legacy** | **gNMI Streaming vs SNMP Polling** | Standardizing OpenConfig YANG schemas across vendors |

---

## 🧪 System Design & Architecture Roadmap

```mermaid
graph TD
    T1["1. 5-Stage Clos Fabric Scaling<br/>(Clos Math & Pod Expansion)"] ==> T2["2. eBGP vs iBGP Control Plane<br/>(RFC 7938 AS-PATH Policies)"]
    T2 ==> T3["3. Sub-50ms Fast Reroute SLAs<br/>(Ti-LFA & BFD Offload)"]
    T3 ==> T4["4. EVPN Multihoming & Loop Prevention<br/>(ESI DF Election & Local Bias)"]
    T4 ==> T5["5. gNMI Telemetry vs SNMP<br/>(OpenConfig Standards)"]

    classDef tpm fill:#004d40,stroke:#80cbc4,color:#ffffff,stroke-width:2px,font-weight:bold;
    class T1,T2,T3,T4,T5 tpm;
```

---

## 📁 System Design Drills & Reference

- **[Google & Hyperscale System Design Masterclass](../interview-prep/google-system-design.md)**: Scenario-based interview drills and architectural trade-offs.
- **[Curriculum Architecture Roadmap](../roadmap.md)**: Complete protocol dependency matrix across all 10 network phases.
