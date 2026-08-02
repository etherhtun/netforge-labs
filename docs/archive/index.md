# Archive

Material that's still worth reading but is no longer the active path.

Nothing here is deleted or hidden — it's kept because the theory holds up even when
the platform underneath it has moved on.

---

<div class="grid cards" markdown>

-   **VXLAN-EVPN on Juniper** &nbsp; <span class="nf-badge plan">reading only</span>

    ---

    A complete written course on vJunos-switch — ten sessions plus five lab guides,
    covering underlay, overlay, L2VNI and L3VNI, multi-tenancy, ESI multihoming,
    external connectivity and multi-site.

    [Read the track →](juniper-vxlan-evpn/index.md)

</div>

---

## Why it was archived

The vJunos-switch labs proved unstable to run: booting four virtual forwarding
planes concurrently on one host repeatedly failed, with nodes coming up degraded
and commits hanging. Host resources weren't the constraint — roughly two nodes was
the practical ceiling, which isn't enough for a spine-leaf fabric.

The hands-on path moved to **Arista cEOS**, which is a container, boots in minutes,
and runs a full fabric on a laptop.

!!! note "The theory is still good"
    EVPN route types, VXLAN encapsulation, route reflector design and multi-tenancy
    are protocol behaviour, not vendor behaviour. Those sessions read perfectly well
    alongside the [current EVPN phase](../courses/04-evpn/index.md) — only the
    configuration syntax differs.

    What you shouldn't do is try to *run* the labs without a cloud VM. See
    [cloud VM setup](../getting-started/cloud-vm.md) if you want to anyway.
