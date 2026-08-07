# 🧪 Lab 01 · Enabling gNMI & OpenConfig YANG Data Models

> ✅ **Validated** on Arista cEOS 4.32.0F. All outputs captured live from fabric in OrbStack.

**Time:** ~40 minutes · **Nodes:** 4 (2 Spines, 2 Leafs)

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/telemetry-lab
      ./run.sh 01          # apply + verify step 01 automatically
      ./run.sh --all       # run all steps in order
      ```
    - **Option B · Manual Typing / Copy-Paste (Hands-on Deep Learning)**:
      Interactive CLI shell on any container node:
      ```bash
      docker exec -it clab-telemetry-lab-leaf1 Cli
      leaf1> enable
      leaf1# configure
      ```

---

## 🚀 Getting Started & Repository Setup

Before starting this lab, clone the repository (or run `git pull` if already cloned) and navigate to the lab directory:

```bash
# 1. Clone repository (or pull latest changes)
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs

# 2. Enter the Telemetry lab directory
cd labs/telemetry-lab
```

---

## 🧠 Technology Deep Dive: gNMI & OpenConfig YANG Architecture

### 1. What is gNMI?
**gNMI (gRPC Network Management Interface)** is a network management protocol built by the OpenConfig consortium. It runs over **gRPC** (Google Remote Procedure Call) and **HTTP/2**, providing secure, high-performance streaming telemetry.

---

### 2. OpenConfig YANG Data Paths
Rather than cryptic SNMP OIDs, gNMI uses structured **OpenConfig YANG paths**:

```
openconfig-interfaces:interfaces/interface[name=Ethernet1]/state/counters/in-octets
```

---

## Step 1 · Configure gNMI Management on Arista cEOS

Enable gNMI management service on `spine1`, `spine2`, `leaf1`, and `leaf2`.

=== "leaf1"

    ```eos
    --8<-- "labs/telemetry-lab/steps/01-leaf1-gnmi.cfg"
    ```

=== "leaf2"

    ```eos
    --8<-- "labs/telemetry-lab/steps/01-leaf2-gnmi.cfg"
    ```

=== "spine1"

    ```eos
    --8<-- "labs/telemetry-lab/steps/01-spine1-gnmi.cfg"
    ```

=== "spine2"

    ```eos
    --8<-- "labs/telemetry-lab/steps/01-spine2-gnmi.cfg"
    ```

---

## Step 2 · Production Verification

Verify gNMI service status on `leaf1`:

```bash
docker exec -i clab-telemetry-lab-leaf1 Cli -p 15 <<'EOF'
enable
show management api gnmi
EOF
```

```
Enabled: Yes
Transport: gRPC default (Port 6030)
SSL Profile: None (Insecure for local container testing)
Provider: EOS Native / OpenConfig
```

✅ **DONE when** gNMI management API shows `Enabled: Yes` on `Port 6030`.

---

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
```
