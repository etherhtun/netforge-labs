# 🧪 Lab 01 · Control Plane Policing (CoPP) & CPU Protection

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~40 minutes · **Nodes:** 4 (2 Spines, 2 Leafs)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/security-lab
      ./run.sh 01          # apply + verify step 01 automatically
      ./run.sh --all       # run all steps in order
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-security-lab-spine1 Cli
      spine1> enable
      spine1# configure
      ```

---

## 🚀 Getting Started & Repository Setup

Before starting this lab, clone the repository (or run `git pull` if already cloned) and navigate to the lab directory:

```bash
# 1. Clone repository (or pull latest changes)
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs

# 2. Enter the Security lab directory
cd labs/security-lab
```

---

## 🧠 Technology Deep Dive: Control Plane Policing (CoPP)

Control Plane Policing (CoPP) protects the router's Central Processing Unit (CPU) against volumetric traffic spikes, BGP SYN floods, and malicious ARP floods. 

CoPP classifies incoming packets destined to the CPU via `class-map` rules and applies hardware rate-limiters (`policy-map type copp`) at the switch ASIC level before packets ever reach the routing protocol daemon:

```
+-------------------+      +-------------------+      +-------------------+
|  INGRESS TRAFFIC  |      |  COPP HARDWARE    |      |  ROUTING ENGINE   |
|  BGP / OSPF / ICMP| +===>|  ASIC RATE-LIMIT  | +===>|  CPU PROCESS      |
|  (100,000 pps)    |      |  (Policed 1000pps)|      |  (Protected)      |
+-------------------+      +-------------------+      +-------------------+
```

---

## Step 1 · Configure Control Plane Policing

Apply CoPP policy maps to `spine1`, `spine2`, `leaf1`, and `leaf2`.

=== "spine1"

    ```eos
    --8<-- "labs/security-lab/steps/01-spine1-copp.cfg"
    ```

=== "spine2"

    ```eos
    --8<-- "labs/security-lab/steps/01-spine2-copp.cfg"
    ```

=== "leaf1"

    ```eos
    --8<-- "labs/security-lab/steps/01-leaf1-copp.cfg"
    ```

=== "leaf2"

    ```eos
    --8<-- "labs/security-lab/steps/01-leaf2-copp.cfg"
    ```

---

## Step 2 · Production Verification

Verify CoPP policy state on `spine1`:

```bash
docker exec -i clab-security-lab-spine1 Cli -p 15 <<'EOF'
enable
show policy-map type copp
EOF
```

```
Service Policy input: POLICY-COPP
  Class-map: CLASS-COPP-BGP (match-all)
    10 permit tcp any any eq bgp
    Police: 1000 pps, burst 1000 packets
    Conformed: 1420 packets, Action: transmit
    Exceeded: 0 packets, Action: drop
```

✅ **DONE when** `show policy-map type copp` displays `POLICY-COPP` actively policing control plane traffic.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
