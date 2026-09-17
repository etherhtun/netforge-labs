# 🧪 Lab 02 · Querying Live Telemetry via pygnmi & Python

> ✅ **Validated** on Python 3.11 & `pygnmi`.

**Time:** ~45 minutes · **Tools:** Python 3, pygnmi library

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
## 🧠 Technology Deep Dive: Python gNMI Client (`pygnmi`)

Python `pygnmi` allows network engineers to query live gNMI telemetry streams over gRPC and output structured JSON dictionaries:

```python
from pygnmi.client import gNMIclient

host = ("172.20.20.43", "6030")
path = ["openconfig-interfaces:interfaces/interface[name=Ethernet1]/state"]

with gNMIclient(target=host, username="admin", password="password", insecure=True) as c:
    result = c.get(path=path)
    print(result)
```

```json
{
  "name": "Ethernet1",
  "admin-status": "UP",
  "oper-status": "UP",
  "counters": {
    "in-octets": 1048293,
    "out-octets": 948201
  }
}
```

✅ **DONE when** `pygnmi` retrieves live interface counters in JSON format over gRPC.
