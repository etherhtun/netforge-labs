<div class="nf-hero" markdown>

# NetForge Labs

**Learn networking by building it.** Stand up real fabrics, break them on purpose,
and understand *why* every line of config is there — not just what to paste.

Everything runs in containers on your own laptop. No hardware, no cloud bill.

<p class="nf-hero-meta">Arista cEOS · containerlab · validated on Apple Silicon</p>

</div>

---

## Start here

<div class="grid cards" markdown>

-   🛠️ **Set up your lab**

    ---

    OrbStack, Docker, containerlab and Arista cEOS on a Mac. Roughly 30 minutes,
    once.

    [Lab setup on macOS →](getting-started/lab-setup-macos.md)

-   🗺️ **See the whole path**

    ---

    Nine phases, from IGP fundamentals through to telemetry and automation — with
    honest status on each.

    [Roadmap →](roadmap.md)

</div>

---

## Available now

<div class="grid cards" markdown>

-   **Phase 4 · VXLAN-EVPN** &nbsp; <span class="nf-badge ok">validated</span>

    ---

    Build a data-centre fabric on Arista cEOS: OSPF underlay, iBGP-EVPN overlay
    with route reflectors, and a VLAN stretched across VXLAN tunnels.

    [Start the lab →](courses/04-evpn/lab-01-vxlan-evpn.md) · [Concepts →](courses/04-evpn/concepts/index.md)

-   **Phase 3 · MPLS & L3VPN** &nbsp; <span class="nf-badge wip">in progress</span>

    ---

    How providers move traffic by swapping labels. Lab 01 (OSPF + LDP underlay) is
    validated; the L3VPN labs are being built.

    [Overview →](courses/03-mpls-l3vpn/index.md) · [Lab 01 →](courses/03-mpls-l3vpn/lab-01-mpls-ldp.md)

-   **Phase 0 · IGP Fundamentals** &nbsp; <span class="nf-badge ok">reading track</span>

    ---

    Link-state routing, OSPF, IS-IS and dual-stack IPv6 — the foundation every
    later phase assumes. No lab; read it and move on.

    [Start reading →](courses/00-igp-fundamentals/index.md)

</div>

The remaining phases — IGP, BGP, internet edge, segment routing, automation, cloud
and telemetry — are mapped out on the [roadmap](roadmap.md) with their current
status. Nothing there is marked finished until it has actually been run.

---

## How every lab works

Each topic follows the same rhythm, so once you've done one you know how to read
them all:

**Mental model → why before how → the mechanism → build it → verify → break it →
interview questions.**

Labs are **gated**: every step ends with a command and a `✅ DONE when…`
condition, so you never build on top of something that silently didn't work.

!!! note "Draft vs validated"
    A lab is marked **⚠️ DRAFT** until its configuration has been run end to end on
    a live fabric, and **✅ Validated** only afterwards. Every command output you
    see in a validated lab was captured from a real run — not written from memory.

    Where something is only partly proven, the page says so and explains what's
    still open. You should never be the one to discover that the hard way.

---

## Reference material

The **[Juniper track](archive/juniper-vxlan-evpn/index.md)** is a complete written course on
VXLAN-EVPN using vJunos-switch — ten sessions plus five lab guides. It's kept as
reading material: the theory applies to any platform, but the labs need a cloud VM
and the hands-on path has moved to Arista cEOS.

Also here: the [IP addressing plan](reference/ipplan.md) and a
[verification cheatsheet](reference/verify-cheatsheet.md).
