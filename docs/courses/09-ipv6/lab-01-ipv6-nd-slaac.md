# 🧪 Lab 01 · IPv6 Neighbor Discovery (ND) & SLAAC / DHCPv6

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~40 minutes · **Nodes:** 4 (2 Routers, 2 Leafs)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/ipv6-lab
      ./run.sh 01          # apply + verify step 01 automatically
      ./run.sh --all       # run all steps in order
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-ipv6-lab-r1-v6 Cli
      r1-v6> enable
      r1-v6# configure
      ```

---

## 🚀 Getting Started & Repository Setup

Before starting this lab, clone the repository (or run `git pull` if already cloned) and navigate to the lab directory:

```bash
# 1. Clone repository (or pull latest changes)
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs

# 2. Enter the IPv6 lab directory
cd labs/ipv6-lab
```

---

## 🧠 Technology Deep Dive: IPv6 Neighbor Discovery (ND)

IPv6 replaces IPv4 ARP (Address Resolution Protocol) broadcasts with ICMPv6 **Neighbor Discovery (ND)**:
- **Neighbor Solicitation (NS / Type 135)**: Multicast request sent to a Solicited-Node Multicast Address (`ff02::1:ffxx:xxxx`) asking for a target node's MAC address.
- **Neighbor Advertisement (NA / Type 136)**: Unicast reply returning the link-layer MAC address.
- **Router Advertisement (RA / Type 134)**: Periodic router broadcasts announcing default gateway and IPv6 network prefixes (`2001:db8:1::/64`) for **SLAAC (Stateless Address Autoconfiguration)**.

---

## Step 1 · Configure IPv6 Dual-Stack Interfaces

Configure IPv6 global unicast addresses (`2001:db8::/64`) and OSPF Area 0 on `r1-v6`, `r2-v6`, `leaf1-v6`, and `leaf2-v6`.

=== "r1-v6"

    ```eos
    --8<-- "labs/ipv6-lab/steps/01-r1-v6-nd.cfg"
    ```

=== "r2-v6"

    ```eos
    --8<-- "labs/ipv6-lab/steps/01-r2-v6-nd.cfg"
    ```

=== "leaf1-v6"

    ```eos
    --8<-- "labs/ipv6-lab/steps/01-leaf1-v6-nd.cfg"
    ```

=== "leaf2-v6"

    ```eos
    --8<-- "labs/ipv6-lab/steps/01-leaf2-v6-nd.cfg"
    ```

---

## Step 2 · Production Verification

Verify IPv6 ping reachability from `r1-v6` to `leaf1-v6`:

```bash
docker exec -i clab-ipv6-lab-r1-v6 Cli -p 15 <<'EOF'
enable
ping ipv6 2001:db8:1::2 repeat 2
EOF
```

```
PING 2001:db8:1::2(2001:db8:1::2) 72 bytes of data.
80 bytes from 2001:db8:1::2: icmp_seq=1 ttl=64 time=0.421 ms
80 bytes from 2001:db8:1::2: icmp_seq=2 ttl=64 time=0.380 ms

--- 2001:db8:1::2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1ms
```

✅ **DONE when** `ping ipv6 2001:db8:1::2` succeeds with `0% packet loss`.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
