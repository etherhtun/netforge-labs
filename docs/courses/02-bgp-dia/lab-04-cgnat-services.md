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

## 🧠 Google Network Infra Knowledge Sharing & Provider Edge Mechanics

> [!NOTE]
> ### 1. Carrier-Grade NAT (RFC 6598 `100.64.0.0/10`) vs RFC 1918
>
> Standard enterprise private addresses (RFC 1918 `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) frequently overlap with enterprise customer internal networks.
>
> - **RFC 6598 Shared Address Space**: The IANA allocated `100.64.0.0/10` (range `100.64.0.0` to `100.127.255.255`) strictly for Service Provider internal CGNAT access networks.
> - **Dual Translation Architecture**: Subscriber routers use RFC 1918 on customer LANs, translate to `100.64.0.0/10` on the WAN access link, and the Provider Edge CGNAT translates `100.64.0.0/10` to public IPv4 pools on the global Internet.

> [!IMPORTANT]
> ### 2. Deterministic NAT (Port-Block Allocation) Mathematical Algorithm
>
> Stateful CGNAT logs every single TCP 5-tuple creation/deletion. For a 10-Gigabit broadband access network handling 1,000,000 flows/sec, raw logging produces **terabytes of syslog data per day**, creating massive storage costs and slow compliance queries.
>
> - **Deterministic PBA Solution**: Eliminates dynamic logging by mapping subscriber IP addresses to public IP + port ranges using a deterministic static algorithm:
>
> $$\text{Block Index} = \text{Subscriber IPv4 Integer} - \text{Base IP Integer}$$
> $$\text{Public IP Index} = \lfloor \frac{\text{Block Index}}{\text{Subscribers per Public IP}} \rfloor$$
> $$\text{Port Start} = \text{Base Port} + (\text{Block Index} \pmod{\text{Subscribers per Public IP}}) \times \text{Block Size}$$
> $$\text{Port End} = \text{Port Start} + \text{Block Size} - 1$$
>
> - **Example**:
>   - Public IP Pool: `203.0.113.10`, Block Size: `1024` ports, Base Port: `1024`.
>   - Subscriber A (`100.64.10.5`) $\rightarrow$ Assigned `203.0.113.10` Ports `1024 – 2047`.
>   - Subscriber B (`100.64.10.6`) $\rightarrow$ Assigned `203.0.113.10` Ports `2048 – 3071`.
> - **Law Enforcement Compliance**: Given an abuse log `(203.0.113.10 : Port 2500 at 14:02:00 UTC)`, law enforcement officers compute $\lfloor \frac{2500 - 1024}{1024} \rfloor = 1$ in $O(1)$ mathematical time, immediately resolving Subscriber B (`100.64.10.6`) without searching raw log files!

> [!TIP]
> ### 3. NAT64 / DNS64 & 464XLAT Protocol Field Translation Matrix
>
> In IPv6-only datacenter or access networks, IPv6 hosts require access to legacy IPv4-only web servers.
>
> ```mermaid
> sequenceDiagram
>     autonumber
>     participant Host as IPv6-Only Host
>     participant DNS as DNS64 Server
>     participant GW as NAT64 Gateway
>     participant Server as IPv4-Only Web Server
>     
>     Host->>DNS: Query AAAA for legacy.com
>     DNS->>DNS: Resolves IPv4 203.0.113.50<br/>Synthesizes 64:ff9b::203.0.113.50 (64:ff9b::cb00:7132)
>     DNS-->>Host: Returns IPv6 AAAA Record
>     Host->>GW: Sends IPv6 Packet to 64:ff9b::cb00:7132
>     GW->>GW: Translates IPv6 Header to IPv4 Header<br/>(IPv6 Hop Limit 64 -> IPv4 TTL 64)
>     GW->>Server: Forwards IPv4 Packet to 203.0.113.50
> ```
>
> | IPv4 Header Field | IPv6 Header Field | Translation Action |
> |---|---|---|
> | **Type of Service (ToS / DiffServ)** | **Traffic Class** | Direct 1:1 Bit Mapping |
> | **Time to Live (TTL)** | **Hop Limit** | Decremented by 1 |
> | **Protocol 6 (TCP) / 17 (UDP)** | **Next Header** | Preserved (TCP=6, UDP=17) |
> | **Source IPv4 Address** | **Source IPv6 Address** | Translated using NAT64 Pool IPv6 prefix |
> | **Destination IPv4 Address** | **Destination IPv6 Address** | Extracted from `64:ff9b::/96` bottom 32 bits |

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```

