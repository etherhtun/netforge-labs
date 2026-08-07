<div class="nf-hero" markdown>

# NetForge Labs

**Learn networking by building it.** Stand up real fabrics on Arista cEOS, break them on purpose, and understand *why* every line of config is there — not just what to paste.

Everything runs in lightweight containers on your own laptop with zero idle overhead.

<p class="nf-hero-meta">Arista cEOS · containerlab · OrbStack on macOS & Linux</p>

</div>

---

## ⚡ Quick Start & Setup

<div class="grid cards" markdown>

-   🛠️ **Set up your lab**

    ---

    OrbStack, Docker, containerlab, and Arista cEOS on Apple Silicon & Mac. Roughly 15 minutes, once.

    [Lab setup guide →](getting-started/lab-setup-macos.md)

-   🗺️ **Curriculum Roadmap**

    ---

    Explore all phases from IGP underlay fundamentals to MPLS L3VPN, Segment Routing, EVPN-VXLAN, and NetDevOps CI/CD pipelines.

    [Explore Roadmap →](roadmap.md)

</div>

---

## 🚀 Validated Courses & Executable Fabrics

<div class="grid cards" markdown>

-   **Phase 4 · VXLAN-EVPN Datacenter Fabrics** &nbsp; <span class="nf-badge ok">5 labs live</span>

    ---

    Enterprise & Hyperscale CLOS fabrics: Pure L2VNI bridging, Symmetric IRB, Anycast Virtual Gateway, ESI All-Active Multihoming, EVPN-VPWS/ELAN, and DCI Multi-Site.

    [Start Phase 4 →](courses/04-evpn/index.md) · [Lab 01 →](courses/04-evpn/lab-01-pure-l2vni.md)

-   **Phase 5 · Network Automation & CI/CD** &nbsp; <span class="nf-badge ok">5 labs live</span>

    ---

    Infrastructure as Code: Jinja2/YAML Data Models, PyATS/Genie automated testing, Batfish pre-flight static analysis, gNMI telemetry, and GitHub Actions CI/CD.

    [Start Phase 5 →](courses/05-netdevops/index.md) · [Lab 01 →](courses/05-netdevops/lab-01-jinja2-yaml.md)

</div>

<div class="grid cards" markdown>

-   **Phase 3.5 · Segment Routing (SR-MPLS)** &nbsp; <span class="nf-badge ok">3 labs live</span>

    ---

    Steering traffic without core state: SRGB range (`16000–23999`), Node/Prefix SIDs, Ti-LFA Sub-50ms Fast Reroute, and SR-PCE BGP Color steering.

    [Start Phase 3.5 →](courses/035-segment-routing/index.md) · [Lab 01 →](courses/035-segment-routing/lab-01-sr-mpls-sids.md)

-   **Phase 3 · MPLS Backbone & L3VPNs** &nbsp; <span class="nf-badge ok">5 labs live</span>

    ---

    Service Provider MPLS architectures: LDP signaling, PHP (Label 3), VRF RDs & RTs, MP-iBGP VPNv4, Inter-AS Options A, B, & C, and Pseudowires.

    [Start Phase 3 →](courses/03-mpls-l3vpn/index.md) · [Lab 01 →](courses/03-mpls-l3vpn/lab-01-mpls-ldp.md)

-   **Phase 1 & 2 · BGP Mechanics & Edge** &nbsp; <span class="nf-badge ok">8 labs live</span>

    ---

    eBGP/iBGP loop prevention, Route Reflectors, Next-Hop-Self, 10-Step Path Selection, BGP Communities, RPKI, and IXP Peering.

    [Start Phase 1 →](courses/01-bgp/index.md) · [Phase 2 →](courses/02-bgp-dia/index.md)

</div>

---

## 💡 How Every Lab Works

Each topic follows the same structured engineering rhythm:

**Mental model $\rightarrow$ why before how $\rightarrow$ protocol mechanics $\rightarrow$ build it $\rightarrow$ verify $\rightarrow$ break it $\rightarrow$ interview drill.**

All labs feature **single-source-of-truth configuration snippets**, **automated step runners (`run.sh`)**, and **live containerlab gate checks**.

!!! note "100% Validated on Fabric"
    Every command output, routing table, and packet capture in NetForge Labs is captured from live Arista cEOS node runs — not written from memory.
