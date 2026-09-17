# 🧪 Lab 05 · Automated Telemetry Alerting & Anomaly Detection

> ✅ **Validated** on Prometheus Alertmanager.

**Time:** ~45 minutes · **Tools:** Alertmanager

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
## 🧠 Technology Deep Dive: Automated Network Alerting

Prometheus Alertmanager evaluates streaming telemetry rules every 5 seconds. If an interface drops or a BGP neighbor flaps, an alert fires instantly:

```yaml
groups:
  - name: network_alerts
    rules:
      - alert: BGPNeighborDown
        expr: openconfig_bgp_neighbor_state_session_state != 1
        for: 10s
        labels:
          severity: critical
        annotations:
          summary: "BGP Session Down on {{ $labels.instance }}"
```

✅ **DONE when** shutting down interface `Ethernet1` triggers an instant `BGPNeighborDown` firing alert.
