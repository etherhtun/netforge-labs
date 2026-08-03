# 1 · How BGP works

BGP runs over **TCP port 179**. That single fact explains a lot: sessions must be
explicitly configured (no discovery), delivery is reliable so BGP never
retransmits, and a session dies when TCP dies.

---

## The state machine

A session walks through six states. Knowing where it stops tells you the cause
immediately.

```mermaid
graph LR
    I["Idle"] --> C["Connect"] --> A["Active"] --> OS["OpenSent"] --> OC["OpenConfirm"] --> E["Established"]
    classDef s fill:#1565c0,stroke:#90caf9,color:#ffffff,stroke-width:2px,font-size:14px;
    classDef g fill:#2e7d32,stroke:#a5d6a7,color:#ffffff,stroke-width:2px,font-size:14px;
    class I,C,A,OS,OC s; class E g;
```

| State | Means | Stuck here → |
|---|---|---|
| **Idle** | not trying, or backing off after failure | no route to the peer, or the peer isn't configured |
| **Connect** | TCP handshake in progress | transient; you rarely catch it |
| **Active** | TCP failed, retrying | **the common failure** — unreachable, filtered, or wrong address |
| **OpenSent** | Open sent, awaiting theirs | AS number mismatch, or router-ID conflict |
| **OpenConfirm** | Open received, awaiting keepalive | rare; usually authentication |
| **Established** | **working** — updates can flow | ✅ |

!!! warning "'Active' is the most misread word in BGP"
    It sounds healthy. It means the opposite: TCP could not be established and BGP
    is retrying. A session flapping between `Idle` and `Active` is a session that
    never came up at all.

    In [Lab 01](../lab-01-ebgp-ibgp.md) the cause is almost always the iBGP peer's
    loopback missing from OSPF — BGP can't open TCP to an address it has no route
    to.

From the live fabric:

```
  BGP state is Established, up for 00:29:18
```

---

## The four messages

| Message | Purpose |
|---|---|
| **Open** | negotiate: AS number, router ID, hold time, capabilities |
| **Update** | the actual work — advertise or withdraw prefixes |
| **Keepalive** | "still here", when there's nothing to say |
| **Notification** | something is wrong; **the session closes immediately** |

Two consequences worth knowing:

**Notification always tears down the session.** BGP has no concept of a warning —
any protocol error ends the session and the code tells you why.

**Capabilities are negotiated in Open.** This is how one protocol carries IPv4,
IPv6, VPNv4 and EVPN: each is a capability the peers agree on at startup. It's also
why adding an address family can bounce a session — the capability set changed.

---

## Timers

Captured from the fabric:

```
  Hold time is 180, keepalive interval is 60 seconds
  Effective minimum hold time is 3 seconds
  Hold timer is active, time left: 00:02:17
```

**Keepalive 60, hold 180** — the defaults, and a standard interview question. Hold
is conventionally 3× keepalive.

The **lower of the two peers' hold times wins**, negotiated in the Open message.
A hold time of 0 means "never time out," which is legal and inadvisable.

!!! tip "Don't chase fast convergence with low timers"
    Dropping to 3/9 detects failure faster but risks tearing down sessions under CPU
    load or transient congestion — and a BGP session bouncing is far more disruptive
    than a few seconds of delay.

    Use **BFD** instead: sub-second detection in a lightweight dedicated protocol
    that tells BGP to drop the neighbour. Same outcome, without making BGP itself
    fragile. See [policy and filtering](04-policy.md).

---

## eBGP and iBGP: same protocol, different rules

The rules differ because eBGP crosses a trust boundary and iBGP doesn't.

| | eBGP | iBGP |
|---|---|---|
| Peers in | different ASes | the same AS |
| Peer address | interface | **loopback** |
| Default TTL | **1** | normal |
| AS path | **prepends** own AS | unchanged |
| Next hop | **sets to self** | unchanged |
| Local preference | not sent | **sent between peers** |
| Re-advertise iBGP routes to | anyone | **never another iBGP peer** |
| Administrative distance | 20 traditionally *(200 on Arista)* | 200 |

The **next hop** row causes most first-deployment failures — that's Lab 01's
subject. The **re-advertise** row is why iBGP needs a full mesh, which is
[scaling](05-scaling.md).

!!! note "Why eBGP defaults to TTL 1"
    It assumes peers are directly connected, so a packet arriving with a decremented
    TTL is not from your neighbour. It's a cheap anti-spoofing measure.

    Peering to a loopback across multiple hops therefore needs `ebgp-multihop` — and
    the more secure alternative, **GTSM**, is covered in
    [policy](04-policy.md).

---

## Why BGP is deliberately slow

OSPF converges in seconds. BGP takes longer, on purpose:

- **No flooding.** Each router evaluates policy and decides what to pass on.
- **Batched updates.** `MRAI` (min route advertisement interval) — 30s between
  updates about the same prefix to an eBGP peer by default — stops a flapping
  prefix propagating globally.
- **Policy runs on every update**, in and out.

For a table of a million routes shared between untrusted networks, damping the
churn matters more than converging quickly. Stability is the feature.

---

## What breaks

| Symptom | Likely cause |
|---|---|
| Stuck `Idle` | no route to the peer, or peer not configured |
| Stuck/flapping `Active` | TCP/179 blocked, wrong peer address, or ACL |
| Stuck `OpenSent` | AS mismatch, or duplicate router ID |
| `Established` but no prefixes | address family not activated, or policy filtering everything |
| Prefixes received but unused | next hop unreachable — see Lab 01 |
| Session bounces periodically | MTU, keepalives dropped, or timers too aggressive |

```bash
show ip bgp summary                    # state of every peer
show ip bgp neighbors <ip>             # timers, capabilities, counters
show ip bgp neighbors <ip> received-routes   # before inbound policy
show ip bgp neighbors <ip> advertised-routes # after outbound policy
```

Those last two are the ones people forget. `received-routes` versus what's in the
table tells you instantly whether **your own inbound filter** is the problem —
which it often is.

---

**Next:** [Path attributes →](02-attributes.md).
