# 🧪 Lab 04 · Programmatic Telemetry & State Parsing (gNMI / pygnmi)

> ✅ **Validated** on gNMI (gRPC Network Management Interface) & Python `pygnmi`.

**Time:** ~45 minutes · **Tools:** gNMI, Protocol Buffers (protobuf), OpenConfig YANG

---

## 🧠 Technology Deep Dive: gNMI vs. Legacy SNMP

Traditional network monitoring relies on **SNMP (Simple Network Management Protocol)**, which polls devices periodically over `UDP 161`. SNMP is CPU-intensive, unencrypted, and slow to reflect link flaps.

**gNMI (gRPC Network Management Interface)** is a unified RPC protocol defined by the OpenConfig consortium:
- **Transport**: HTTP/2 over TLS (`TCP 6030` or `TCP 50051`).
- **Data Encoding**: Google Protocol Buffers (protobuf) or JSON.
- **YANG Modeling**: Uses OpenConfig YANG paths (e.g. `/interfaces/interface[name=Ethernet1]/state/oper-status`).
- **Modes**: Supports `Get`, `Set`, and `Subscribe` (streaming telemetry).

---

## 💻 Querying Device State with Python (`pygnmi`)

```python
from pygnmi.client import gNMIclient

host = ("172.20.20.33", "6030")
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

✅ **DONE when** `pygnmi` retrieves live OpenConfig interface state over gRPC.
