# 🎯 Milestone-Driven Learning Paths

> Choose your engineering journey in **AI & Hyperscale Infrastructure Architecture**, **Network Site Reliability Engineering (SRE)**, **Cybersecurity & DevSecOps**, **NetDevOps & Automation**, **Low-Latency Financial Engineering**, or **Technical Program Management (TPM)**. 
>
> Every learning path is structured in progressive milestone stages backed by executable containerlab topologies, automated guided runners (`./run.sh --guided`), and live verification tests.

---

## 🗺️ Choose Your Career Journey

<div class="grid cards" markdown>

-   🌐 **1. Network for AI & Hyperscale Architect** &nbsp; <span class="nf-badge ok">40–50 hrs</span>

    ---

    **For engineers building next-generation AI clusters & cloud backbones.**

    - **Lossless AI Transport**: RoCEv2, PFC (802.1Qbb), ECN & buffer tuning
    - **Datacenter Fabrics**: 5-Stage Clos, EVPN-VXLAN, ESI All-Active Multihoming
    - **Routing & Backbone**: RFC 7938 BGP, MP-BGP VPNv4, SR-MPLS & Ti-LFA

    [Start AI & Hyperscale Path →](network-engineer.md)

-   🤖 **2. Network SRE & Observability** &nbsp; <span class="nf-badge ok">30–35 hrs</span>

    ---

    **For engineers ensuring five-nines availability and real-time visibility.**

    - **Sub-Second Convergence**: BFD hardware offload & route flap dampening
    - **Push Telemetry**: gNMI gRPC Protobuf, OpenConfig YANG, Prometheus & Grafana
    - **Reliability Engineering**: CoPP CPU protection, PyATS assertions & incident drills

    [Start Network SRE Path →](network-sre.md)

-   🔒 **3. Cybersecurity & DevSecOps** &nbsp; <span class="nf-badge ok">30–35 hrs</span>

    ---

    **For engineers defending network fabrics and cloud-native workloads.**

    - **Network Hardening**: Control Plane Policing (CoPP), iACLs, VRF microsegmentation
    - **Zero-Trust Identity**: OAuth2, OIDC, mutual TLS (mTLS), and HashiCorp Vault
    - **Runtime & AppSec**: OWASP Top 10 WAF, Falco eBPF kernel detection, and SIEM

    [Start Cybersecurity Path →](cybersecurity-engineer.md)

-   🤖 **4. NetDevOps & Infrastructure Automation** &nbsp; <span class="nf-badge ok">35–40 hrs</span>

    ---

    **For developers treating network infrastructure as code.**

    - **Data Modeling**: YAML Single Source of Truth & Jinja2 template rendering
    - **Pre-Flight Static Analysis**: Batfish AST simulation proving reachability offline
    - **CI/CD Automation**: GitHub Actions, Containerlab headless testbeds, and PyATS

    [Start NetDevOps Path →](netdevops-engineer.md)

-   ⚡ **5. Low-Latency Financial Network Engineer** &nbsp; <span class="nf-badge ok">25–30 hrs</span>

    ---

    **For high-frequency trading (HFT) and co-location architects.**

    - **Multicast Market Feeds**: PIM-SM, Anycast RP, and IGMP fast-leave tuning
    - **Sub-50ms Failover**: Aggressive microsecond BFD timers on optical cross-connects
    - **Line-Rate Security**: IEEE 802.1AE MACsec AES-256-GCM hardware encryption

    [Start Low-Latency Path →](financial-network-engineer.md)

-   📋 **6. TPM & Hyperscale System Design** &nbsp; <span class="nf-badge ok">20–25 hrs</span>

    ---

    **For infrastructure program leaders and systems architects.**

    - **Fabric Sizing Math**: Non-blocking Clos formulas and oversubscription ratios
    - **Protocol Governance**: RFC 7938 eBGP vs. iBGP blast-radius containment
    - **SLA & Vendor RFPs**: Sub-50ms Ti-LFA error budgets and OpenConfig standards

    [Start TPM System Design Path →](technical-program-manager.md)

</div>

---

## 📊 Comprehensive Path Comparison Matrix

| Learning Path | Primary Focus | Flagship Technologies | Target Industry Roles | Est. Time |
|---|---|---|---|---|
| **🌐 AI & Hyperscale Architect** | Non-blocking AI fabrics & core routing | RoCEv2, PFC/ECN, EVPN-VXLAN, BGP, SR-MPLS | Architect - Network for AI, Staff Infrastructure Architect | 40–50 hrs |
| **🤖 Network SRE & Observability** | Sub-second failover & streaming telemetry | BFD, gNMI, OpenConfig, Prometheus, PyATS | Network SRE, Production Reliability Engineer | 30–35 hrs |
| **🔒 Cybersecurity & DevSecOps** | Infrastructure defense & Zero-Trust | CoPP, iACLs, VRF, Falco eBPF, mTLS, WAF | Cybersecurity Engineer, DevSecOps Architect | 30–35 hrs |
| **🤖 NetDevOps & Automation** | Infrastructure as Code & CI/CD | YAML, Jinja2, Batfish, GitHub Actions, pygnmi | NetDevOps Engineer, Automation Architect | 35–40 hrs |
| **⚡ Low-Latency Financial** | Nanosecond HFT & multicast tick feeds | PIM-SM, IGMP, BFD microsecond, MACsec | Low-Latency Network Engineer, HFT Architect | 25–30 hrs |
| **📋 TPM & System Design** | Capacity math, SLAs & program governance | 5-Stage Clos math, BGP blast radius, RFP criteria | Technical Program Manager, Infrastructure Director | 20–25 hrs |

---

## 🚀 How Every Path is Executed

1. **Step-by-Step Curriculum**: Read the mental model, protocol mechanics, and failure modes in the portal.
2. **Automated Guided Runner**: Launch `./run.sh --guided` inside the lab folder on macOS (OrbStack) or Linux (Docker).
3. **Inspect or Type**: Preview configs or apply them manually using the provided syntax.
4. **Instant Verification Gates**: Run automated verifier scripts that assert routing tables, forwarding states, and end-to-end ping reachability.
