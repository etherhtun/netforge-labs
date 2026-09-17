# 🧪 Lab 04 · Real-Time Visual Grafana Network Dashboards

> ✅ **Validated** on Grafana 10.3.

**Time:** ~45 minutes · **Tools:** Grafana Dashboard

!!! tip "Quick Start — Step-by-Step Execution Guide (Location: `labs/telemetry-lab/`)"
    **Step 1 · Deploy the Lab Fabric (if not already running)**
    ```bash
    cd labs/telemetry-lab
    sudo containerlab deploy -t topology.clab.yml --max-workers 1
    ```

    **Step 2 · Launch the Fully Guided Interactive Walkthrough**
    ```bash
    ./run.sh --guided
    ```

    ??? note "Alternative Execution Options (Automated Push or Manual CLI)"
        - **Fast Automated Script Push**:
          ```bash
          ./run.sh 01          # apply + verify step 01 automatically
          ./run.sh --all       # run all steps in order
          ```
        - **Manual Line-by-Line CLI Execution**:
          Interactive CLI shell on any container node:
          ```bash
          docker exec -it clab-telemetry-lab-leaf1 Cli
          ```

---
## 🧠 Technology Deep Dive: Network Observability Dashboards

**Grafana** connects to Prometheus time-series data to render real-time dashboards of network throughput, BGP neighbor states, and interface errors:

- **Interface Throughput (bits/sec)**:
  `rate(openconfig_interfaces_interface_state_counters_in_octets[1m]) * 8`
- **BGP Peer State (Established = 1)**:
  `openconfig_bgp_neighbor_state_session_state == 1`

Access the local dashboard at `http://localhost:3000`.

✅ **DONE when** Grafana renders real-time throughput graphs for cEOS interfaces.
