# Interview questions — Linux networking

Linux networking comes up in every automation, SRE and NetDevOps interview, and
increasingly in plain network-engineer ones — because the boxes are Linux now.

---

## Namespaces and virtual networking

??? question "What is a network namespace?"
    An isolated copy of the entire network stack — its own interfaces, routing
    table, ARP cache and firewall rules. Processes inside see only that stack.
    Two namespaces can both have an `eth1` addressed `10.1.1.1` with no conflict,
    which is what lets one kernel host many virtual routers.

??? question "What is a veth pair and what is it for?"
    Two linked virtual interfaces: whatever enters one end exits the other. Putting
    one end in each of two namespaces creates a virtual cable between them. It's how
    containerlab wires topologies and how container networking generally connects a
    container to its host.

??? question "How would you find what a container's interface is connected to?"
    `ip -d link show <intf>` inside its namespace. The output includes
    `link-netns <name>`, naming the namespace holding the peer, and the `@ifN`
    suffix gives the peer's interface index. That reports what the kernel actually
    built, as opposed to what a topology file claims.

??? question "Create two namespaces connected by a cable."
    ```bash
    ip netns add r1; ip netns add r2
    ip link add veth-r1 type veth peer name veth-r2
    ip link set veth-r1 netns r1
    ip link set veth-r2 netns r2
    ip netns exec r1 ip addr add 10.0.0.1/30 dev veth-r1
    ip netns exec r1 ip link set veth-r1 up
    ip netns exec r2 ip addr add 10.0.0.2/30 dev veth-r2
    ip netns exec r2 ip link set veth-r2 up
    ```

??? question "How do you run a command inside a container's network namespace?"
    Get the PID with `docker inspect -f '{{.State.Pid}}' <container>`, then
    `nsenter -t <pid> -n <command>`. `-n` selects the network namespace
    specifically. Useful because the container often lacks the tools you want —
    `nsenter` runs the *host's* binaries against the container's network stack.

---

## Containers

??? question "How does a container differ from a virtual machine?"
    A VM emulates hardware and runs its own kernel. A container is an ordinary
    process on the host kernel, isolated by **namespaces** (what it can see) and
    **cgroups** (what it can use). No hardware emulation, no second kernel — hence
    seconds to boot rather than minutes, at the cost of sharing the host kernel.

??? question "Why do containerised network OSes exist at all?"
    Because a NOS is fundamentally a routing daemon programming a forwarding table
    — and Linux already has a forwarding table. Once you accept that, the hardware
    emulation a VM provides is unnecessary for control-plane work. cEOS, cRPD and
    SONiC all take this route.

??? question "Why does restarting a lab container break its links?"
    The veth ends live in the container's network namespace, which belongs to its
    main process. Restarting destroys the namespace and every interface in it. The
    container returns with an empty namespace and nothing re-wires it, because the
    orchestrator only wires at creation. Destroy and redeploy the topology instead.

??? question "A heredoc piped into docker exec applies nothing and exits 0. Why?"
    `docker exec` doesn't attach stdin without `-i`. The heredoc is written to a
    pipe nobody reads; the process starts, sees empty stdin, exits cleanly. Add
    `-i`. Use `-it` only for interactive sessions — a TTY with piped input mangles
    output.

---

## Reading the stack

??? question "Why use ip instead of ifconfig?"
    `ifconfig` is unmaintained and can't show network namespaces, multiple
    addresses per interface, or policy routing. `ip` covers all of it and is the
    supported tool. Mapping: `ifconfig`→`ip addr`, `route -n`→`ip route`,
    `arp -a`→`ip neigh`, `netstat -i`→`ip -s link`.

??? question "What's the difference between ip route and ip route get?"
    `ip route` prints the table. `ip route get <dst>` asks the kernel what it would
    actually do with a packet to that destination, applying longest-prefix match and
    policy rules. When "the route looks right but traffic goes elsewhere",
    `ip route get` answers the real question.

??? question "What does proto gated mean in a routing table?"
    Which subsystem installed the route. `kernel` means automatic from an interface
    address; `static` means manual; `gated`/`bgp`/`ospf` means a routing daemon.
    On a Linux-based NOS, your OSPF and BGP routes appear as daemon-installed
    entries in the ordinary kernel table.

??? question "The neighbour table shows FAILED for a next hop. What does that tell you?"
    Layer 2 resolution failed — no MAC for that IP, so packets have nowhere to go
    regardless of routing. That's a much sharper finding than "ping fails": it rules
    out layer 3 and points at the segment, VLAN, or the neighbour being down.

??? question "How would you confirm a neighbour's hellos are actually arriving?"
    `tcpdump -i <intf> -nn 'proto ospf'` in the namespace. If the packets are
    visible but the protocol reports no neighbour, the wire is fine and the mismatch
    is in packet *contents* — timers, area, authentication, MTU. If nothing arrives,
    the problem is below the protocol and there's no point debugging the protocol.

??? question "Interface counters show rising errors. What do you suspect?"
    Errors typically point at MTU or physical/link issues; drops point at buffers or
    policy. Comparing RX on one end against TX on the other localises loss — if TX
    climbs and the far RX doesn't, frames aren't arriving and the problem is the
    path between them.

---

## Troubleshooting method

??? question "Give an order for diagnosing a broken link."
    Bottom-up, because a lower-layer failure makes every layer above look broken:
    (1) `ip -br link` — is it up, is `LOWER_UP` present; (2) `ip -br addr` — correct
    address and mask; (3) `ip neigh` — is the next hop resolving; (4)
    `ip route get` — what would the kernel actually do; (5) `tcpdump` — what's
    genuinely on the wire. Most faults resolve at step 1 or 3, which is why starting
    at 5 wastes time.

??? question "A command exits 0 and prints nothing. Is that success?"
    Not necessarily, and it's worth being suspicious. Silent success and silent
    no-op look identical from an exit code. The `docker exec` stdin bug is exactly
    this — the safe response is to verify the intended state changed, rather than
    trusting the exit code.

??? question "Why is understanding Linux useful for a network engineer who doesn't administer servers?"
    Because the devices are Linux. Modern NOSes run routing daemons that program the
    kernel FIB; labs are namespaces and veth pairs; automation runs over SSH and
    APIs on Linux hosts. When a NOS gives an answer that makes no sense, the
    explanation is often one layer down — and without Linux, that layer is opaque.
