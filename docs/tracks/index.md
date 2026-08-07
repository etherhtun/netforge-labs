# 🎯 Role-Based Specialization Tracks

> Choose your career track in **Network Engineering**, **Cybersecurity**, **NetDevOps & Automation**, or **Technical Program Management (TPM)**. Each track provides a targeted, step-by-step curriculum with executable containerlab topologies and hands-on drills.

---

## 🌐 1. Network Infrastructure & Hyperscale Track

> **Target Roles**: Network Engineer, Senior/Staff Network Infrastructure Engineer, Datacenter Architect.

Master core routing underlays, BGP path selection, MPLS service provider backbones, Segment Routing, and VXLAN-EVPN datacenter CLOS fabrics.

<div class="grid cards" markdown>

-   **Phase 0 · IGP Fundamentals**

    ---

    OSPFv2/v3 Area 0 & IS-IS Wide Metrics (RFC 5305).

    [Start Course →](../courses/00-igp-fundamentals/index.md)

-   **Phase 1 · BGP Mechanics & Policies**

    ---

    eBGP, iBGP, Route Reflectors, and 10-step BGP Path Selection.

    [Start Course →](../courses/01-bgp/index.md)

-   **Phase 2 · BGP-DIA & Internet Edge**

    ---

    Dual-ISP Multi-homing, BGP Communities, RPKI, and BFD failover.

    [Start Course →](../courses/02-bgp-dia/index.md)

-   **Phase 3 · MPLS Backbone & L3VPNs**

    ---

    LDP signaling, PHP, VRF RDs/RTs, Inter-AS Options A/B/C, and Pseudowires.

    [Start Course →](../courses/03-mpls-l3vpn/index.md)

-   **Phase 3.5 · Segment Routing (SR-MPLS)**

    ---

    SRGB range (`16000–23999`), Node SIDs, Sub-50ms Ti-LFA FRR, and SR-PCE.

    [Start Course →](../courses/035-segment-routing/index.md)

-   **Phase 4 · VXLAN-EVPN Datacenter Fabrics**

    ---

    Pure L2VNI, Symmetric IRB, ESI All-Active Multihoming, and DCI.

    [Start Course →](../courses/04-evpn/index.md)

-   **Phase 6 · Enterprise WAN Edge**

    ---

    Dual-ISP eBGP Multihoming (Active/Standby & Active/Active) and BFD.

    [Start Course →](../courses/06-hybrid-cloud/index.md)

-   **Phase 9 · IPv6 Transition & Dual-Stack**

    ---

    IPv6 ND/SLAAC, BGP Unnumbered over IPv6 Link-Local (RFC 5549), and 6PE/6VPE.

    [Start Course →](../courses/09-ipv6/index.md)

</div>

---

## 🔒 2. Cybersecurity & Network Microsegmentation Track

> **Target Roles**: Network Security Engineer, SecOps Specialist, Security Architect.

Protect infrastructure against control plane floods, implement zero-trust VRF isolation, enforce infrastructure ACLs, and configure MACsec line-rate encryption.

<div class="grid cards" markdown>

-   **Phase 8 · Network Security & Datacenter Segmentation**

    ---

    Control Plane Policing (CoPP), VRF Microsegmentation, iACLs, and 802.1AE MACsec encryption.

    [Start Security Track →](../courses/08-security/index.md)

-   **BGP Security & RPKI ROV**

    ---

    Protect BGP edges against route hijacking using Route Origin Validation (ROV) and RPKI validator daemons.

    [Start RPKI Security →](../courses/02-bgp-dia/lab-02-rpki-security.md)

-   **IPv6 Boundary Protection & NAT64/DNS64**

    ---

    Enforce strict perimeter control and stateful NAT64 translation boundaries.

    [Start Boundary Security →](../courses/09-ipv6/lab-04-nat64-dns64.md)

</div>

---

## 🤖 3. NetDevOps & Infrastructure Automation Track

> **Target Roles**: NetDevOps Engineer, Automation Developer, Cloud Network Architect.

Treat network infrastructure as code: render dynamic configs via Jinja2/YAML, parse CLI states with PyATS/Genie, run pre-flight static analysis via Batfish AST, and stream gNMI telemetry into Prometheus & Grafana.

<div class="grid cards" markdown>

-   **Linux & Networking Foundations**

    ---

    Shell scripting, text processing, SSH key auth, systemd, git, and kernel network namespaces.

    [Start Foundations →](../courses/linux-foundations/index.md)

-   **Phase 5 · Network Automation & CI/CD Pipelines**

    ---

    Jinja2/YAML Data Models, PyATS/Genie, Batfish AST static pre-flight analysis, gNMI, and GitHub Actions CI/CD.

    [Start NetDevOps Track →](../courses/05-netdevops/index.md)

-   **Phase 7 · Streaming Telemetry & Observability**

    ---

    gNMI gRPC protobuf streams, OpenConfig YANG schemas, Prometheus metrics, and real-time Grafana dashboards.

    [Start Telemetry Track →](../courses/07-telemetry/index.md)

</div>

---

## 📋 4. Hyperscale System Design & Program Management Track (TPM)

> **Target Roles**: Technical Program Manager (TPM), Infrastructure Program Lead, Network Solutions Architect.

Designed for Technical Program Managers leading large-scale infrastructure deployments, vendor RFPs, and hyperscale fabric buildouts. Focuses on system design trade-offs, blast radius containment, SLA budget calculations, and failure domain analysis.

<div class="grid cards" markdown>

-   **Google & Hyperscale System Design Masterclass**

    ---

    Scenario-based interview drills and architectural trade-offs: 5-Stage Clos scaling, eBGP vs. iBGP, Ti-LFA micro-loop avoidance, and EVPN ESI failure modes.

    [Start System Design Masterclass →](../interview-prep/google-system-design.md)

-   **Curriculum Architecture Roadmap**

    ---

    Full overview of all 10 network phases, protocol dependencies, and containerized topology footprints.

    [View Roadmap →](../roadmap.md)

</div>
