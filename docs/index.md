<div class="nf-hero" markdown>

# NetForge Labs

**Learn networking by building it.** Stand up real fabrics on Arista cEOS, break them on purpose, and understand *why* every line of config is there — not just what to paste.

Everything runs in 100% local, lightweight containers on your own laptop with zero idle overhead.

<p class="nf-hero-meta">Arista cEOS · containerlab · OrbStack on macOS & Linux</p>

</div>

---

## ⚡ Quick Start & System Design

<div class="grid cards" markdown>

-   🛠️ **Set up your lab**

    ---

    OrbStack, Docker, containerlab, and Arista cEOS on Apple Silicon & Mac. Roughly 15 minutes, once.

    [Lab setup guide →](getting-started/lab-setup-macos.md)

-   🎯 **Google System Design Drill**

    ---

    Scenario-based interview drills for Senior & Staff Network Infrastructure Engineers at Google, Meta, and Apple.

    [Interview Drills →](interview-prep/google-system-design.md)

</div>

---

## 🚀 Validated Courses & Executable Fabrics

<div class="grid cards" markdown>

-   **Phase 4 · VXLAN-EVPN Datacenter Fabrics** &nbsp; <span class="nf-badge ok">5 labs live</span>

    ---

    CLOS fabrics: Pure L2VNI, Symmetric IRB, Anycast Virtual Gateway, ESI All-Active Multihoming, EVPN-VPWS/ELAN, and DCI Multi-Site.

    [Start Phase 4 →](courses/04-evpn/index.md)

-   **Phase 5 · Network Automation & CI/CD** &nbsp; <span class="nf-badge ok">5 labs live</span>

    ---

    Infrastructure as Code: Jinja2/YAML Data Models, PyATS/Genie, Batfish pre-flight static analysis, gNMI, and GitHub Actions CI/CD.

    [Start Phase 5 →](courses/05-netdevops/index.md)

</div>

<div class="grid cards" markdown>

-   **Phase 7 · Streaming Telemetry & Observability** &nbsp; <span class="nf-badge ok">5 labs live</span>

    ---

    gNMI gRPC protobuf streams, OpenConfig YANG models, Prometheus metrics, and real-time Grafana visual dashboards.

    [Start Phase 7 →](courses/07-telemetry/index.md)

-   **Phase 8 · Network Security & Microsegmentation** &nbsp; <span class="nf-badge ok">4 labs live</span>

    ---

    Control Plane Policing (CoPP) CPU protection, VRF microsegmentation with ACL filters, Infrastructure ACLs (iACLs), and MACsec.

    [Start Phase 8 →](courses/08-security/index.md)

-   **Phase 9 · IPv6 Transition & Dual-Stack** &nbsp; <span class="nf-badge ok">4 labs live</span>

    ---

    IPv6 ND/SLAAC, BGP Unnumbered over IPv6 Link-Local (RFC 5549 / RFC 8950), 6PE/6VPE over MPLS, and NAT64/DNS64 translation.

    [Start Phase 9 →](courses/09-ipv6/index.md)

</div>

<div class="grid cards" markdown>

-   **Phase 3.5 · Segment Routing (SR-MPLS)** &nbsp; <span class="nf-badge ok">3 labs live</span>

    ---

    SRGB range (`16000–23999`), Node/Prefix SIDs, Ti-LFA Sub-50ms Fast Reroute, and SR-PCE BGP Color steering.

    [Start Phase 3.5 →](courses/035-segment-routing/index.md)

-   **Phase 3 · MPLS Backbone & L3VPNs** &nbsp; <span class="nf-badge ok">5 labs live</span>

    ---

    LDP signaling, PHP (Label 3), VRF RDs & RTs, MP-iBGP VPNv4, Inter-AS Options A/B/C, and Pseudowires.

    [Start Phase 3 →](courses/03-mpls-l3vpn/index.md)

-   **Phase 6 · Enterprise WAN Edge Multihoming** &nbsp; <span class="nf-badge ok">4 labs live</span>

    ---

    Dual-ISP eBGP Multihoming (Primary/Backup), AS-PATH Prepending, BGP Communities, BFD sub-second failover, and local RPKI ROV.

    [Start Phase 6 →](courses/06-hybrid-cloud/index.md)

</div>

---

## 💡 How Every Lab Works

Each topic follows the same structured engineering rhythm:

**Mental model $\rightarrow$ why before how $\rightarrow$ protocol mechanics $\rightarrow$ build it $\rightarrow$ verify $\rightarrow$ break it $\rightarrow$ interview drill.**

All labs feature **single-source-of-truth configuration snippets**, **automated step runners (`run.sh`)**, and **live containerlab gate checks**.
