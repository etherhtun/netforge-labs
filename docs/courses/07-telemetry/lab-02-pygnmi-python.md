# 🧪 Lab 02 · Querying Live Telemetry via pygnmi & Python

> ✅ **Validated** on Python 3.11 & `pygnmi`.

**Time:** ~45 minutes · **Tools:** Python 3, pygnmi library

---

## 🚀 Getting Started & Repository Setup

```bash
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs/labs/telemetry-lab
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
