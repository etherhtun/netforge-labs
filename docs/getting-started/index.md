# Get Started

Everything in NetForge runs in containers on your own machine. No hardware, no
cloud bill, nothing to reserve.

Set this up once and every lab in every phase will run.

---

<div class="grid cards" markdown>

-   **1 · Lab setup on macOS** &nbsp; <span class="nf-badge ok">start here</span>

    ---

    OrbStack, Docker, containerlab and Arista cEOS on Apple Silicon. About 30
    minutes, once.

    [Set up your lab →](lab-setup-macos.md)

-   **2 · Docker & containerlab**

    ---

    How the topology files work, and the deploy / destroy commands you'll use in
    every lab.

    [Read →](containerlab.md)

</div>

<div class="grid cards" markdown>

-   **Cloud VM** &nbsp; <span class="nf-badge plan">optional</span>

    ---

    Only needed for the Juniper archive labs, which are too heavy for a laptop.
    Everything current runs locally.

    [Read →](cloud-vm.md)

-   **Team quickstart** &nbsp; <span class="nf-badge plan">optional</span>

    ---

    Short version for people who already know containerlab and just want the
    commands.

    [Read →](team-quickstart.md)

</div>

---

!!! tip "Do the macOS setup first"
    The other pages assume a working containerlab host. Once
    [lab setup](lab-setup-macos.md) is done, go to
    [Courses](../courses/index.md) and pick a phase.

Once you're set up, the fastest thing to actually build is
**[Phase 4 · VXLAN-EVPN](../courses/04-evpn/lab-01-pure-l2vni.md)** — it's fully
validated and gets you a working fabric end to end.
