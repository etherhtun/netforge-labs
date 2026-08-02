# Foundations — Linux for Network Engineers

> 📖 **Reading track — no lab required.** Every command here runs against the lab
> you already have. Nothing extra to build.

Every lab in NetForge runs on Linux. containerlab builds topologies out of Linux
**network namespaces** and **veth pairs**; cEOS is a Linux container; the `show ip
route` output you read in a lab has a Linux kernel routing table sitting directly
underneath it.

You can complete the labs without knowing any of that. But when something breaks in
a way the NOS CLI can't explain, the answer is almost always one layer down — and
without this, that layer is a black box.

---

## Why this exists

Three of the hardest bugs hit while building this curriculum were **not networking
problems**. They were Linux problems wearing networking costumes:

| Symptom | Looked like | Actually was |
|---|---|---|
| Nodes never booted, `Connected 0 interfaces` | broken topology file | cEOS counts `eth*` interfaces; `Ethernet1` never matched |
| Config commands returned instantly, changed nothing | CLI syntax error | no stdin — missing `docker exec -i` |
| Interfaces came up as type `Unknown` | corrupt image | a boot race between concurrent containers |

None of those are findable from a routing CLI. All three are obvious once you can
see the Linux layer.

---

## What you'll understand

<div class="grid cards" markdown>

-   **[1 · Namespaces and veth pairs](01-namespaces-veth.md)**

    ---

    How one machine pretends to be a dozen routers. Network namespaces, virtual
    cables, and exactly how containerlab wires a topology — shown on a running
    fabric.

-   **[2 · Reading the Linux network stack](02-inspecting.md)**

    ---

    `ip`, routes, neighbours, and `tcpdump`. Where your NOS's routing table
    actually lives, and how to watch packets the CLI won't show you.

-   **[3 · Containers, and why cEOS behaves as it does](03-containers.md)**

    ---

    What a container really is, and how that explains the `ethN` naming rule, the
    silent `docker exec` failure, and why you must never `docker restart` a lab
    node.

-   **[Interview questions](interview-questions.md)**

    ---

    Self-test bank. Linux networking comes up in every automation, SRE and
    NetDevOps interview, and increasingly in plain network-engineer ones.

</div>

---

## Where this sits

This is a **prerequisite**, not a numbered phase. It comes before
[Phase 0](../00-igp-fundamentals/index.md) in usefulness even though the phases
don't depend on it formally.

| It matters most for | Because |
|---|---|
| **Every lab here** | containerlab is namespaces and veth pairs, nothing more |
| **[Phase 5 · NetDevOps](../index.md)** | Ansible, Python and CI/CD all assume Linux fluency |
| **Modern NOSes** | SONiC, cRPD and cEOS are Linux; the network stack is the OS stack |

!!! tip "You already have the lab"
    Everything below runs in the OrbStack VM you set up in
    [lab setup](../../getting-started/lab-setup-macos.md). If a fabric is running,
    you can follow along command for command.

    All output shown was **captured from a live three-node fabric** — nothing here
    is illustrative or from memory.
