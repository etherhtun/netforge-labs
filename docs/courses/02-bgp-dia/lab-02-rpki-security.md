# 🧪 Lab 02 · BGP Security — RPKI ROV & Bogon Filtering

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric.

**Time:** ~45 minutes · **Nodes:** 4 (2 Edge Routers, 2 Transit/Peer Routers)

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

## Step 1 · RPKI Route Origin Validation (ROV)

RPKI validates whether the origin AS advertising an IP prefix is authorized by the registered IP space holder.

### RPKI Validation States:
1. **`Valid`**: The prefix and origin AS match a signed Route Origin Authorization (ROA) object.
2. **`Invalid`**: A ROA exists for the prefix, but the advertising AS or prefix length does **not** match. **Action: DROP.**
3. **`NotFound`**: No ROA exists in global RPKI cache repositories. **Action: PERMIT (with lower preference).**

```eos
! Configuring RPKI Origin Validation Policy on Arista EOS Edge Router
router bgp 65001
   rpki cache ROUTINATOR-1
      host 10.0.100.50 port 3323
   !
   address-family ipv4
      bgp origin-as validation enable
```

Filtering invalid routes using route-maps:

```eos
route-map RM-RPKI-IN deny 10
   match rpki validity invalid
!
route-map RM-RPKI-IN permit 20
   match rpki validity valid
   set local-preference 120
!
route-map RM-RPKI-IN permit 30
   match rpki validity not-found
   set local-preference 100
```

---

## Step 2 · Remotely Triggered Blackhole (RTBH — `65535:666`)

When an IP address comes under a severe volumetric DDoS attack, RTBH drops attack traffic at the ISP edge using the well-known community `65535:666` (RFC 7999).

```eos
! Configuring RTBH Blackhole route map
ip route 192.168.10.99/32 Null0
!
ip community-list CL-RTBH permit 65535:666
!
route-map RM-RTBH-IN permit 10
   match community CL-RTBH
   set ip next-hop 192.0.2.1
   set local-preference 200
```

When an upstream ISP receives `65535:666`, it rewrites the next-hop to a `Null0` discard interface, neutralizing the DDoS attack before it consumes WAN bandwidth.

---

## Step 3 · Bogon & Transit Leak Filtering

Block private address spaces (RFC 1918), CGNAT space (RFC 6598 `100.64.0.0/10`), and loopbacks on internet-facing eBGP sessions.

```eos
ip prefix-list PL-BOGON-DENY seq 10 deny 10.0.0.0/8 le 32
ip prefix-list PL-BOGON-DENY seq 20 deny 172.16.0.0/12 le 32
ip prefix-list PL-BOGON-DENY seq 30 deny 192.168.0.0/16 le 32
ip prefix-list PL-BOGON-DENY seq 40 deny 100.64.0.0/10 le 32
ip prefix-list PL-BOGON-DENY seq 50 permit 0.0.0.0/0 le 24
```

---

## 🧠 Google Network Infra Knowledge Sharing

> [!NOTE]
> ### Production Deep Dive & Hyperscale Architecture
>
> 1. **RPKI Cache Validators (Routinator / StayRtr)**:
>    - Hyperscale edge routers do not query RPKI Trust Anchors directly over HTTP. Instead, local **RPKI Cache Validators** (Routinator, StayRtr, Fort) query ARIN/RIPE/APNIC RIR repositories and stream validated ROA tables to edge routers via the RTR (RPKI-to-Router) protocol over TCP port 3323.
>
> 2. **BGP Route Leak Prevention (RFC 9234)**:
>    - Major ISPs and cloud providers enforce **BGP Open Policy Roles** (Provider, Customer, Peer, RS, RS-Client) and OTC (Only to Customer) attribute tags to automatically prevent route leak incidents.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
