# Get Started

Everything in NetForge Labs runs in lightweight containers on your own laptop or on a cloud virtual machine. No dedicated hardware is needed, and you have complete control over your lab environments.

Choose your host setup below, then explore how containerlab orchestrates real network fabrics.

---

## 🛠️ Step 1 · Choose Your Host Environment

<div class="grid cards" markdown>

-   **1A · Lab setup on macOS** &nbsp; <span class="nf-badge ok">Local Laptop</span>

    ---

    Run 100% locally on Apple Silicon (M-series) or Intel Mac using OrbStack, Docker, containerlab, and Arista cEOS under Rosetta. About 15 minutes, zero cloud cost.

    [Set up on macOS →](lab-setup-macos.md)

-   **1B · Lab setup on GCP** &nbsp; <span class="nf-badge ok">Cloud VM</span>

    ---

    Run on a dedicated Google Cloud Compute Engine VM (Ubuntu 24.04). Ideal if your laptop has limited RAM/CPU, or you need a 24/7 cloud lab accessible anywhere.

    [Set up on GCP →](cloud-vm.md)

</div>

---

## ⚡ Step 2 · Master the Platform & Engineering Mechanics

<div class="grid cards" markdown>

-   **2 · Docker & Containerlab CLI**

    ---

    Understand the anatomy of topology files (`topology.clab.yml`), and master essential commands for deploying, inspecting, graphing, and destroying labs.

    [Read CLI Guide →](containerlab.md)

-   **3 · How the lab works**

    ---

    Deep dive into Linux network namespaces and virtual ethernet (veth) pairs that power containerlab topologies under the hood.

    [Read Architecture →](how-the-lab-works.md)

</div>

<div class="grid cards" markdown>

-   **4 · Hybrid execution model**

    ---

    How to combine automated `./run.sh` step runners with line-by-line CLI copy-pasting, state diffing, and clean container teardowns.

    [Read Quickstart →](team-quickstart.md)

-   **5 · Lab Troubleshooting**

    ---

    Why cEOS behaves as it does: resolving parallel boot races (`--max-workers 1`), namespace lifecycles, and interface naming rules.

    [Read Troubleshooting →](lab-troubleshooting.md)

</div>

---

!!! tip "Complete your host setup first"
    Choose either **[macOS setup](lab-setup-macos.md)** or **[GCP setup](cloud-vm.md)**. Once your host is ready, jump directly into any phase in [Courses](../courses/index.md):
    - **[Phase 4 · VXLAN-EVPN Datacenter Fabrics](../courses/04-evpn/lab-01-pure-l2vni.md)**
    - **[Phase 3.5 · Segment Routing & Ti-LFA](../courses/035-segment-routing/lab-01-sr-mpls-sids.md)**
    - **[Phase 5 · Network Automation & CI/CD Pipelines](../courses/05-netdevops/lab-01-jinja2-yaml.md)**
