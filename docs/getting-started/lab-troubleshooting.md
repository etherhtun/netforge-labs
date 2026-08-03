# Lab troubleshooting — why cEOS behaves as it does

Three bugs cost real hours while building this curriculum. None were networking
problems. All three become obvious once you know what a container actually is.

---

## A container is not a small VM

A virtual machine emulates hardware and runs its own kernel. A container does
neither. It is **an ordinary Linux process** that the kernel has lied to about its
surroundings, using two features:

- **Namespaces** — control what a process can *see*: its own PIDs, mounts,
  hostname, and (the one we care about) its own network stack.
- **cgroups** — control what it can *use*: CPU, memory, I/O.

That's it. `docker inspect -f '{{.State.Pid}}'` returned `30498` in
[how the lab works](how-the-lab-works.md) — a PID on your host's process table, visible
to `ps`, killable with `kill`. Nothing is virtualised.

This is why a cEOS fabric boots in seconds while vJunos takes minutes: there's no
kernel to start, no hardware to emulate. It's also why cEOS shares your host
kernel, and why some kernel-level behaviour can't be faithfully emulated.

!!! note "The consequence that matters"
    Because a container is just a process with a private network namespace, **the
    NOS inside it is subject to Linux rules** — process lifecycle, stdin/stdout,
    interface naming conventions. When it misbehaves, Linux semantics are as likely
    to be the cause as anything in the routing stack.

    All three bugs below are exactly that.

---

## Bug 1 — the interface naming rule

**Symptom:** nodes hang at `Connected 0 interfaces out of 2`. EOS never boots. The
topology file looks correct.

**Cause:** the topology used `Ethernet1` as the endpoint name:

```yaml
links:
  - endpoints: ["p1:Ethernet1", "pe1:Ethernet1"]   # ✗ hangs
```

cEOS's entrypoint waits for containerlab to finish wiring before starting EOS, and
it detects completion by **counting interfaces matching `eth*`** in its namespace.
A veth literally named `Ethernet1` never matches that pattern, so the count stays
at zero and the entrypoint waits forever.

**Fix** — lowercase `ethN` in the topology:

```yaml
links:
  - endpoints: ["p1:eth1", "pe1:eth1"]   # ✓
```

Inside EOS these still appear as `Ethernet1` and `Ethernet2`. The Linux name and
the NOS name are different layers; only the Linux one has to match the pattern.

**Why Linux knowledge finds this:** `ip -br link` inside the namespace shows the
interface present and up. The wiring worked. Something is *looking for a name* and
not finding it — which points at the entrypoint, not the topology.

---

## Bug 2 — the silent config failure

**Symptom:** a heredoc config block returns instantly, prints nothing, exits `0`.
No config applied. No error.

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 <<'EOF'    # ✗ silent no-op
configure
interface Ethernet1
 ip address 10.1.1.1/24
EOF
```

**Cause:** `docker exec` does not attach stdin unless told to. The heredoc is
written to a pipe nothing is reading. `Cli` starts, finds stdin empty, exits
cleanly — and a clean exit with no output looks exactly like success.

**Fix** — `-i` for interactive stdin:

```bash
docker exec -i clab-ceos-mpls-scratch-p1 Cli -p 15 <<'EOF'   # ✓
configure
interface Ethernet1
 ip address 10.1.1.1/24
EOF
```

!!! warning "This one is dangerous precisely because it's quiet"
    A failure that exits `0` and prints nothing is worse than a crash. Scripts
    continue, later steps "succeed" against a device that was never configured, and
    the eventual symptom appears somewhere unrelated.

    **Rule: a heredoc into `docker exec` always needs `-i`.** If a config block
    returns with no output at all, assume nothing was applied and verify before
    continuing.

The related flag, `-t`, allocates a TTY. Use `-it` for an interactive session you
type into; use `-i` alone when piping input from a script. `-t` with piped input
produces mangled output.

---

## Bug 3 — never `docker restart` a lab node

**Symptom:** after restarting a container, its data-plane interfaces are gone.
`show interfaces` lists only management. No error explains it.

**Cause:** containerlab created the veth pairs and moved one end into each
container's namespace. That namespace belongs to the container's main process.
Restarting the container **destroys the namespace**, and everything inside it —
including the veth ends — goes with it.

The container comes back with a fresh, empty namespace. containerlab isn't running,
so nothing re-wires it.

**Fix** — recreate the topology rather than the container:

```bash
sudo containerlab destroy -t topology.clab.yml
sudo containerlab deploy -t topology.clab.yml
```

!!! tip "Reloading from inside doesn't work either"
    `reload` at the EOS prompt restarts the NOS process, which in a container means
    restarting PID 1 — which ends the container. Same outcome.

    To re-apply configuration without rebuilding, push config rather than restarting
    anything.

---

## The boot race

**Symptom:** a node occasionally comes up with `show interfaces Ethernet1 status`
reporting type `Unknown`. Destroy and redeploy and it's fine.

**Cause:** timing. Under Rosetta emulation on Apple Silicon, x86 containers run
slower than native. Booting several at once, a node's EOS can begin initialising
interfaces before containerlab has finished moving every veth end into place.

**Fix** — serialise startup:

```bash
sudo containerlab deploy -t topology.clab.yml --max-workers 1
```

And always health-check before configuring: every data-plane interface should report
a real type, never `Unknown`.

!!! note "Why this is a Linux-shaped bug"
    Nothing is wrong with EOS or the topology. Two independent processes — the
    entrypoint and containerlab's wiring — race, and emulation widens the window.

    That class of bug is invisible from a routing CLI and unremarkable once you
    know the container is a process being set up concurrently with its own
    interfaces.

---

## The pattern

| Bug | Looked like | Actually was |
|---|---|---|
| `Connected 0 interfaces` | broken topology | interface **name pattern** |
| Config silently not applied | CLI error | **stdin** not attached |
| Interfaces gone after restart | corrupted node | **namespace** destroyed |
| Interface type `Unknown` | bad image | **race** between processes |

Every one is a Linux behaviour surfacing through a networking tool. None are
diagnosable from `show` commands, and all four are ordinary once you can see the
layer underneath.

That's the argument for this track: not that you'll configure Linux, but that when
the NOS gives you an answer that makes no sense, you'll know where to look.

---

For transferable Linux skills — shell, ssh, git, parsing device output — see
**[Foundations · Linux](../courses/linux-foundations/index.md)**.
