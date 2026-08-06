# Foundations — Linux & Physical Infrastructure

> 📖 **Reading track.** Every command runs on the lab host you already have.

You will not be asked to administer a Linux server. You **will** be asked to check
BGP on forty routers, pull the config off all of them, diff last week's against
today's, and explain why the automation job failed at 3am.

That's what this covers: the Linux a network engineer actually uses.

---

## Why it matters more than it used to

| Then | Now |
|---|---|
| Log into a box, type commands | Script against fifty boxes |
| Config lives on the device | Config lives in **git** |
| Read `show` output on screen | **Parse** it, diff it, alert on it |
| Vendor CLI only | Vendor CLI **plus REST/gNMI over HTTP** |
| Manual change window | CI pipeline that must be debugged when it fails |

Every item in the right column is a Linux skill. So is passing the interview for
the job that expects them.

---

## What you'll learn

<div class="grid cards" markdown>

-   **[1 · Shell fluency](01-shell.md)**

    ---

    Pipes, redirection, exit codes, variables and loops — building up to a script
    that checks every device in a fabric and reports only what's broken.

-   **[2 · Parsing device output](02-text-processing.md)**

    ---

    `grep`, `awk`, `sed` and `jq`. Turning `show` output and JSON APIs into
    something a script can act on.

-   **[3 · SSH properly](03-ssh.md)**

    ---

    Keys instead of passwords, the agent, `~/.ssh/config`, and jump hosts.
    The foundation every automation tool sits on.

-   **[4 · Processes, services and logs](04-services.md)**

    ---

    `systemd`, `journalctl`, and the host-side network tools — `ss`, `curl`, `nc`,
    `mtr`. Where things fail and how to find out why.

-   **[5 · Git for network engineers](05-git.md)**

    ---

    Config in version control, meaningful diffs, branches and rollback. Required
    before any automation work.

-   **[6 · Linux kernel networking](06-kernel-networking.md)**

    ---

    `iproute2`, policy routing, network namespaces, `tcpdump` flag filters, kernel
    packet processing, and TCP socket troubleshooting.

-   **[7 · Layer 1 optics & physical infrastructure](07-physical-layer.md)**

    ---

    Transceivers (SFP+ to OSFP), MMF/SMF fiber physics, Digital Optical Monitoring (DOM),
    RS-FEC error correction, and port breakouts.

-   **[Interview questions](interview-questions.md)**

    ---

    Self-test bank covering the whole track.

</div>

---

## The one example that makes the case

A single line that checks BGP across an entire fabric — run against the
[Phase 1 lab](../01-bgp/lab-01-ebgp-ibgp.md):

```bash
for n in r1 r2 r3; do
  printf "%-4s " "$n"
  docker exec clab-bgp-lab-$n Cli -p 15 -c "show ip bgp summary" | grep -c Estab
done
```

```
r1   2
r2   1
r3   1
```

Three devices is a party trick. Three hundred is the job — and it's the same line.

---

## Where this leads

| Next | Why it needs this |
|---|---|
| **Every lab here** | you'll script the repetitive parts instead of typing them |
| **Phase 5 · NetDevOps** | Ansible, Python and CI/CD assume all of this |
| **Any modern NOS** | cEOS, SONiC and cRPD are Linux underneath |

!!! note "Looking for how containerlab works?"
    Namespaces, veth pairs and the cEOS container quirks moved to
    **[how the lab works](../../getting-started/how-the-lab-works.md)** and
    **[lab troubleshooting](../../getting-started/lab-troubleshooting.md)**.

    That material explains *this* lab environment. Useful, but it isn't a
    transferable Linux skill, and it shouldn't have been filed as one.
