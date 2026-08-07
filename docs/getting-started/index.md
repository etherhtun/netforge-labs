# Get Started

Everything in NetForge Labs runs in lightweight containers on your own machine. No hardware, no cloud bills, and zero background idle overhead.

Set this up once and every lab in every phase will run cleanly.

---

<div class="grid cards" markdown>

-   **1 · Lab setup on macOS** &nbsp; <span class="nf-badge ok">start here</span>

    ---

    OrbStack, Docker, containerlab and Arista cEOS on Apple Silicon. About 15 minutes, once.

    [Set up your lab →](lab-setup-macos.md)

-   **2 · Docker & containerlab**

    ---

    How topology files (`topology.clab.yml`) work, and the deploy / destroy commands used in every lab.

    [Read →](containerlab.md)

</div>

<div class="grid cards" markdown>

-   **3 · How the lab works**

    ---

    Deep dive into Linux network namespaces and virtual ethernet (veth) pairs that power containerlab topologies.

    [Read →](how-the-lab-works.md)

-   **4 · Hybrid execution model**

    ---

    How to use automated `./run.sh` step runners, line-by-line CLI copy-pasting, and clean container teardown (`docker rm -f`).

    [Read →](team-quickstart.md)

</div>

---

!!! tip "Do the macOS setup first"
    The other pages assume a working containerlab host. Once [lab setup](lab-setup-macos.md) is done, jump into any phase in [Courses](../courses/index.md).

Once set up, jump straight into:
- **[Phase 4 · VXLAN-EVPN Datacenter Fabrics](../courses/04-evpn/lab-01-pure-l2vni.md)**
- **[Phase 3.5 · Segment Routing & Ti-LFA](../courses/035-segment-routing/lab-01-sr-mpls-sids.md)**
- **[Phase 5 · Network Automation & CI/CD Pipelines](../courses/05-netdevops/lab-01-jinja2-yaml.md)**
