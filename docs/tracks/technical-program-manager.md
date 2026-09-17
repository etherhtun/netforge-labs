# 📋 Technical Program Manager (TPM) & System Design Learning Path

> 🚀 **Hyperscale Architecture & Technical Leadership**: Master 5-Stage Clos fabric scaling math, eBGP vs. iBGP architectural trade-offs, blast radius containment, SLA / convergence budget calculations, and multi-vendor RFP execution.

---

## 📊 Learning Path Overview

| Metric | Target Specification |
|---|---|
| **Estimated Completion Time** | **20 – 25 Hours** (Architectural analysis, system design drills, and case studies) |
| **Milestone Stages** | **5 Progressive Stages** (Clos Scaling Math → Routing Architecture → SLA & Convergence Budgets → Overlay Virtualization → Vendor RFPs & Telemetry) |
| **Target Roles** | Technical Program Manager (TPM) - Infrastructure, Network Solutions Architect, Infrastructure Program Lead, Engineering Director |
| **Target Employers** | Google, Meta, Apple, AWS, Microsoft, ByteDance, NVIDIA, Global Financial Institutions, and Cloud Infrastructure Consultancies |

---

## 🧠 Core TPM Engineering & Leadership Pillars

| Program Domain | Key Architectural Decisions | Leadership & Program Function |
|---|---|---|
| **Fabric Scaling Math** | **5-Stage Clos vs. 2-Tier Spine-Leaf** | ASIC port-density calculations, oversubscription ratios, and modular pod expansion planning |
| **Routing Protocol Selection** | **eBGP (RFC 7938) vs. iBGP + RRs** | Blast-radius containment, routing loop elimination, and global ASN allocation governance |
| **Convergence SLAs** | **Sub-50ms Ti-LFA vs. IGP Timers** | Establishing production availability budgets (99.999%), link failover SLAs, and error budgets |
| **Overlay Virtualization** | **EVPN-VXLAN ESI vs. Proprietary MLAG** | Decoupling physical underlay from tenant overlays and eliminating vendor hardware lock-in |
| **Telemetry Standardization** | **gNMI Streaming vs. SNMP Polling** | Standardizing multi-vendor OpenConfig schemas across Arista, Cisco, and whitebox switches |

---

## 🗺️ 5-Stage Progressive Milestone Roadmap

<div class="nf-stepper">

  <a class="nf-step-card" href="#stage-1-5-stage-clos-fabric-sizing-capacity-math">
    <div class="nf-step-num">01</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 1 · 5-Stage Clos Fabric Sizing & Capacity Math</h4>
        <span class="nf-badge ok">Fabric Math</span>
      </div>
      <p class="nf-step-desc">Calculate non-blocking Clos port radix formulas and oversubscription ratios across Tier-1 Leaf, Tier-2 Spine, and Tier-3 Super-Spine switches.</p>
      <div class="nf-chips">
        <span class="nf-chip">5-Stage Clos</span>
        <span class="nf-chip">Port Radix Formulas</span>
        <span class="nf-chip">Oversubscription Ratios</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-2-routing-architecture-blast-radius-design">
    <div class="nf-step-num">02</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 2 · Routing Architecture & Blast Radius Design</h4>
        <span class="nf-badge ok">Governance</span>
      </div>
      <p class="nf-step-desc">Compare RFC 7938 eBGP leaf-spine fabrics against IGP+iBGP to eliminate routing loops and contain failure blast radiuses.</p>
      <div class="nf-chips">
        <span class="nf-chip">RFC 7938 eBGP</span>
        <span class="nf-chip">ASN Allocation Strategy</span>
        <span class="nf-chip">Failure Domain Isolation</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-3-high-availability-convergence-sla-budgets">
    <div class="nf-step-num">03</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 3 · High-Availability & Convergence SLA Budgets</h4>
        <span class="nf-badge ok">99.999% SLAs</span>
      </div>
      <p class="nf-step-desc">Calculate production availability budgets and evaluate sub-50ms Ti-LFA fast reroute vs. traditional IGP convergence timers.</p>
      <div class="nf-chips">
        <span class="nf-chip">Ti-LFA Sub-50ms</span>
        <span class="nf-chip">Error Budgeting</span>
        <span class="nf-chip">BFD Hardware Offload</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-4-multi-tenant-overlays-open-standards">
    <div class="nf-step-num">04</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 4 · Multi-Tenant Overlays & Open Standards</h4>
        <span class="nf-badge ok">Open Standards</span>
      </div>
      <p class="nf-step-desc">Decouple physical fabrics from tenant services using EVPN-VXLAN with ESI multihoming, avoiding proprietary MLAG/vPC lock-in.</p>
      <div class="nf-chips">
        <span class="nf-chip">EVPN-VXLAN</span>
        <span class="nf-chip">ESI Multihoming</span>
        <span class="nf-chip">Multi-Vendor Interop</span>
      </div>
    </div>
  </a>

  <a class="nf-step-card" href="#stage-5-telemetry-governance-vendor-rfp-delivery">
    <div class="nf-step-num">05</div>
    <div class="nf-step-content">
      <div class="nf-step-header">
        <h4 class="nf-step-title">Stage 5 · Telemetry Governance & Vendor RFP Delivery</h4>
        <span class="nf-badge ok">Vendor RFPs</span>
      </div>
      <p class="nf-step-desc">Write standardized multi-vendor OpenConfig telemetry specs and mandate automated PyATS acceptance tests for hardware procurement.</p>
      <div class="nf-chips">
        <span class="nf-chip">OpenConfig YANG</span>
        <span class="nf-chip">gNMI Governance</span>
        <span class="nf-chip">Automated RFP Acceptance</span>
      </div>
    </div>
  </a>

</div>

---

## 🚀 Interactive Lesson Directory (Click Any Lesson to Start)

| Milestone Stage | Architecture & Program Focus | Clickable Lessons & System Designs | Technical Focus | Action |
|---|---|---|---|---|
| **Stage 1**<br/>`Clos Sizing Math` | ASIC Port Radix Math, Oversubscription Ratios, Super-Spine Pods | • [EVPN-VXLAN Clos Fabric Design](../courses/04-evpn/index.md)<br/>• [Hyperscale System Design Masterclass](../interview-prep/google-system-design.md) | Pod Math | [Start Stage 1 →](../interview-prep/google-system-design.md) |
| **Stage 2**<br/>`BGP Governance` | RFC 7938 eBGP Clos Design, Blast Radius, ASN Allocation Policies | • [Phase 1 · BGP Fundamentals & Architecture](../courses/01-bgp/index.md)<br/>• [Phase 1 · Lab 03: Route Reflector Hierarchy](../courses/01-bgp/lab-03-route-reflectors.md) | ASN Model | [Start Stage 2 →](../courses/01-bgp/index.md) |
| **Stage 3**<br/>`SLA & FRR Budgets` | Sub-50ms Ti-LFA Fast Reroute, BFD Hardware Offload, Error Budgets | • [Segment Routing (SR-MPLS) Ti-LFA Architecture](../courses/035-segment-routing/lab-02-ti-lfa-frr.md)<br/>• [WAN Edge BFD Sub-Second Failover](../courses/06-hybrid-cloud/lab-03-bfd-subsecond-failover.md) | 99.999% SLAs | [Start Stage 3 →](../courses/035-segment-routing/lab-02-ti-lfa-frr.md) |
| **Stage 4**<br/>`Multi-Tenant Overlays` | RFC 8365/7432 EVPN-VXLAN, ESI All-Active Multihoming vs MLAG Lock-in | • [EVPN Lab 03: ESI All-Active Multihoming](../courses/04-evpn/lab-03-esi-multihoming.md)<br/>• [EVPN Lab 05: Multi-Site DCI Architecture](../courses/04-evpn/lab-05-evpn-dci-multisite.md) | Open Standards | [Start Stage 4 →](../courses/04-evpn/lab-03-esi-multihoming.md) |
| **Stage 5**<br/>`Vendor RFP Delivery` | OpenConfig YANG Governance, gNMI Telemetry SLAs, PyATS Pre-Checks | • [Phase 7 · Streaming Telemetry & Observability](../courses/07-telemetry/index.md)<br/>• [Phase 5 · Automated Network Testing with PyATS](../courses/05-netdevops/lab-02-pyats-verification.md) | RFP Criteria | [Start Stage 5 →](../courses/07-telemetry/index.md) |

---

## 🧪 Detailed Milestone Curricula

### 📍 Stage 1: 5-Stage Clos Fabric Sizing & Capacity Math
- **Core Focus**: Translating business compute requirements into non-blocking or strictly-bounded oversubscribed network topologies.
- **Formulas & Trade-offs**:
    - Maximum leaves supported by $S$ spines: $N_{leaf} = S \times \text{uplinks per leaf}$.
    - Non-blocking server capacity given $k$-port switches: $N_{servers} = \frac{k^2}{2}$.
    - Calculating bandwidth oversubscription ratios ($1:1$, $2:1$, $3:1$) across Tier-1 (Leaf), Tier-2 (Spine), and Tier-3 (Super-Spine) layers.

### 📍 Stage 2: Routing Architecture & Blast Radius Design
- **Core Focus**: Selecting control plane protocols that prevent cascade failures across multi-pod datacenters.
- **Key Comparisons**:
    - **RFC 7938 eBGP**: Distinct ASN per tier/rack; AS-PATH automatically eliminates loops; routing policy applied at AS boundaries.
    - **iBGP + Route Reflectors**: Requires full IGP underlay; risk of route oscillations without careful cluster-id hierarchy.

### 📍 Stage 3: High-Availability & Convergence SLA Budgets
- **Core Focus**: Calculating downtime risk and defining strict architectural failover parameters for contractual SLAs.
- **Key Concepts**:
    - Sub-50ms Topology-Independent Loop-Free Alternate (Ti-LFA).
    - BFD timer aggregation vs. ASIC CPU load.
    - Establishing 99.99% ("four nines") vs. 99.999% ("five nines") quarterly error budgets.

### 📍 Stage 4: Multi-Tenant Overlays & Open Standards
- **Core Focus**: Avoiding vendor lock-in when evaluating multi-million dollar switch hardware procurement.
- **Key Concepts**:
    - Why proprietary multi-chassis link aggregation (Cisco vPC, Arista MLAG) creates fragile dual-control-plane bugs.
    - How RFC 8365/7432 EVPN-VXLAN with ESI (Ethernet Segment Identifier) provides multi-vendor, all-active multihoming.

### 📍 Stage 5: Telemetry Governance & Vendor RFP Delivery
- **Core Focus**: Writing technical specifications and automated validation gates for hardware RFPs and carrier acceptance.
- **Key Concepts**:
    - Mandating OpenConfig YANG schemas and gNMI streaming telemetry support in vendor contracts.
    - Requiring automated PyATS / Batfish pre-deployment gate checks before accepting network hardware delivery.

---

## 📁 System Design Drills & Reference

- **[Google & Hyperscale System Design Masterclass](../interview-prep/google-system-design.md)**: Scenario-based interview drills and architectural trade-offs.
- **[Curriculum Architecture Roadmap](../roadmap.md)**: Complete protocol dependency matrix across all 10 network phases.
- **[EVPN-VXLAN Clos Fabric Course](../courses/04-evpn/index.md)**: The underlying leaf-spine fabric implementation.
- **[Streaming Telemetry Course](../courses/07-telemetry/index.md)**: The gNMI/OpenConfig telemetry pipeline.

---

## 🎯 System Design Interview Drills for TPMs

### ❓ Question 1: How do you design a non-blocking fabric for 16,384 GPU servers using 64-port 800G switches?
**Answer:**
A 2-tier spine-leaf fabric using 64-port switches can connect at most $32 \times 32 = 1,024$ nodes non-blocking (each leaf has 32 downlinks to GPUs and 32 uplinks to spines). To scale to 16,384 GPUs, a **3-tier (5-stage Clos) architecture** is required:
1. **Tier-1 (Leaf / ToR)**: 512 leaf switches, each with 32 downlinks to GPUs (total 16,384 GPUs) and 32 uplinks to Tier-2 spines.
2. **Tier-2 (Spine / Fabric)**: Grouped into Pods. Each pod contains leaves connected to 32 spines.
3. **Tier-3 (Super-Spine / Core)**: Aggregates inter-pod traffic across the entire cluster, maintaining 1:1 non-blocking bisectional bandwidth.

### ❓ Question 2: Why do hyperscalers prefer eBGP (RFC 7938) over IGP+iBGP for datacenter fabric control planes?
**Answer:**
1. **Loop Prevention**: BGP uses `AS-PATH` as a built-in loop prevention mechanism. If an update circles back to an AS, it is instantly discarded without complex graph computations.
2. **Blast Radius Containment**: Route flapping in one rack or pod can be damped and filtered at AS boundaries, preventing full-fabric SPF recalculation storms that occur in link-state IGPs (OSPF/IS-IS).
3. **Multi-Vendor Uniformity**: BGP is universally supported with identical operational semantics across Arista, Cisco, Juniper, and whitebox SONiC platforms.
