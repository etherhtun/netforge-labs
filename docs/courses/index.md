# Courses

Nine phases, from routing foundations to running a network in production. Each is
standalone, but they're ordered so every one builds on the last.

Nothing is marked finished until it has actually been run. See the
[roadmap](../roadmap.md) for how each phase is progressing.

---

## Start here

<div class="grid cards" markdown>

-   **Foundations · Linux** &nbsp; <span class="nf-badge ok">prerequisite</span>

    ---

    Shell scripting, parsing device output, SSH keys and jump hosts, systemd and
    logs, and git for config management. The Linux a network engineer actually uses.

    [Start reading →](linux-foundations/index.md)

</div>

## Foundations

<div class="grid cards" markdown>

-   **Phase 0 · IGP Fundamentals** &nbsp; <span class="nf-badge ok">reading track</span>

    ---

    Link-state routing, OSPF, IS-IS, dual-stack IPv6. The underlay every later
    phase assumes. No lab — read it and move on.

    [Start reading →](00-igp-fundamentals/index.md)

-   **Phase 1 · BGP Fundamentals & Policies** &nbsp; <span class="nf-badge ok">4 labs validated</span>

    ---

    eBGP and iBGP, route reflectors, path selection, and the policy tooling that
    decides which route actually wins.

    [Overview →](01-bgp/index.md) · [Lab 01 →](01-bgp/lab-01-ebgp-ibgp.md) · [Concepts →](01-bgp/concepts/index.md)

-   **Phase 2 · BGP-DIA & Internet Edge** &nbsp; <span class="nf-badge plan">planned</span>

    ---

    Multi-homing to providers, RPKI, peering, and NAT / CGNAT at the edge.

</div>

## Service provider

<div class="grid cards" markdown>

-   **Phase 3 · MPLS & L3VPN** &nbsp; <span class="nf-badge wip">in progress</span>

    ---

    Moving traffic by swapping labels. LDP, RSVP-TE, and L3VPN options A, B and C.
    Lab 01 is validated; the L3VPN labs are being built.

    [Overview →](03-mpls-l3vpn/index.md) · [Lab 01 →](03-mpls-l3vpn/lab-01-mpls-ldp.md)

-   **Phase 3.5 · Segment Routing** &nbsp; <span class="nf-badge plan">planned</span>

    ---

    SR-MPLS, SR-PCE, Ti-LFA and the basics of SRv6. How hyper-scalers (FAANG) steer traffic without building state in the core, and how SDN controllers integrate with IGPs.

</div>

## Data centre

<div class="grid cards" markdown>

-   **Phase 4 · EVPN Services** &nbsp; <span class="nf-badge ok">4 labs validated</span>

    ---

    VXLAN-EVPN fabrics, EVPN-ELAN and EVPN-VPWS, and stretching EVPN between sites
    with DCI.

    [Overview →](04-evpn/index.md) · [Lab 01 →](04-evpn/lab-01-vxlan-evpn.md) · [Concepts →](04-evpn/concepts/index.md)

</div>

## Operations

<div class="grid cards" markdown>

-   **Phase 5 · NetDevOps (Network Automation)** &nbsp; <span class="nf-badge plan">planned</span>

    ---

    NetBox (Source of Truth), Python (Nornir/Netmiko), and Ansible. Treating infrastructure as code with CI/CD pipelines to validate ECMP paths and deploy fabrics programmatically.

-   **Phase 6 · Hybrid Cloud & Edge** &nbsp; <span class="nf-badge plan">planned</span>

    ---

    AWS Transit Gateway, BGP over DirectConnect, IPsec and SD-WAN.

-   **Phase 7 · Telemetry & Observability** &nbsp; <span class="nf-badge plan">planned</span>

    ---

    Replacing legacy SNMP with gNMI and OpenConfig streaming telemetry. Building a modern SRE monitoring stack with Prometheus, Grafana, and TRex traffic generation.

</div>

---

!!! tip "Not sure where to start?"
    **New to routing** — Phase 0, then 1 and 2. **Data-centre focus** — Phase 1,
    then jump straight to Phase 4, which is live today. **Service provider** —
    Phase 1, then 3 and 3.5. **Already know the protocols** — Phases 5 and 7 are
    where most of the actual job is.

Also available: the [Juniper VXLAN-EVPN archive](../archive/juniper-vxlan-evpn/index.md)
— a complete written course kept as reading material.
