# 🧪 Lab 03 · Streaming Telemetry Collectors & Prometheus Metrics

> ✅ **Validated** on Prometheus 2.50.

**Time:** ~45 minutes · **Tools:** Prometheus, gNMI Exporter

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
## 🧠 Technology Deep Dive: Time-Series Data Collection

**Prometheus** stores time-series metric data identified by metric names and key-value pairs (labels). The gNMI Exporter subscribes to gNMI streams from cEOS nodes and exposes them on `http://localhost:9090/metrics` for Prometheus scraping:

```yaml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: 'ceos-gnmi'
    static_configs:
      - targets: ['172.20.20.41:6030', '172.20.20.43:6030']
```

✅ **DONE when** Prometheus status targets page (`http://localhost:9090/targets`) shows all cEOS nodes in `UP` state.
