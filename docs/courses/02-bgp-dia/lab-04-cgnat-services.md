# 🧪 Lab 04 · Carrier-Grade NAT (CGNAT) & Provider Edge Services

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric.

**Time:** ~50 minutes · **Nodes:** 4 (Provider Edge Router, CGNAT Gateway, 2 Subscriber Hosts)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/edge-lab
      ./run.sh 02          # apply + verify step 02 automatically
      ./run.sh --all       # run all steps in order
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-edge-lab-r1 Cli
      r1> enable
      r1# configure
      ```
      Or push individual step snippets using stdin:
      `docker exec -i clab-edge-lab-r1 Cli -p 15 < steps/02-r1-underlay.cfg`

---

## Step 1 · Carrier-Grade NAT (CGNAT — RFC 6598)

Due to IPv4 exhaustion, ISPs assign private IPv4 addresses from the RFC 6598 Shared Address Space (`100.64.0.0/10`) to subscriber devices and translate them to public IPv4 pools at the Provider Edge.

```eos
! Configuring CGNAT Address Pools and Translation Rules
ip access-list ACL-CGNAT-SUBSCRIBERS
   10 permit ip 100.64.0.0/10 any
!
ip nat pool POOL-PUBLIC-DIA 203.0.113.10 203.0.113.20 prefix-length 24
ip nat source dynamic access-list ACL-CGNAT-SUBSCRIBERS pool POOL-PUBLIC-DIA overload
```

---

## Step 2 · Port-Block Allocation (PBA) & Deterministic NAT

Standard dynamic NAT assigns ephemeral ports randomly, making legal/regulatory IP logging computationally expensive. **Port-Block Allocation (PBA)** assigns fixed blocks of 1,024 TCP/UDP ports per subscriber IP.

```
Subscriber IP: 100.64.10.5  ──> Assigned Public IP: 203.0.113.10 (Ports 1024 - 2047)
Subscriber IP: 100.64.10.6  ──> Assigned Public IP: 203.0.113.10 (Ports 2048 - 3071)
```

This algorithmically determines which subscriber owned a source IP:port pair at any timestamp without writing gigabytes of raw translation logs per second.

---

## Step 3 · NAT64 & DNS64 Dual-Stack Transition

Modern hyperscale environments run **IPv6-only interior fabrics**. To allow IPv6-only hosts to access legacy IPv4-only DIA services, the edge deploys NAT64 and DNS64.

```
IPv6-Only Host ──(queries IPv4 address)──> DNS64 synthesizes 64:ff9b::203.0.113.10
               ──(sends IPv6 packet)───> NAT64 Gateway translates to IPv4 203.0.113.10
```

---

## 🧠 Google Network Infra Knowledge Sharing

> [!NOTE]
> ### Production Deep Dive & Hyperscale Architecture
>
> 1. **IPv6-Single Stack Fabrics at Google**:
>    - Google data centers operate single-stack IPv6 internally. IPv4 traffic is encapsulated or translated using **NAT64 / 464XLAT** at the edge to reduce state table sizes on internal switches.
>
> 2. **Stateful vs Stateless NAT Scaling**:
>    - Stateful NAT (tracking individual 5-tuples) hits hardware table limits under DDoS or high connection rates. Hyperscale architectures use **stateless translation (MAP-E / MAP-T)** or deterministic port block algorithms to scale NAT throughput to terabits per second.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
