# 🧪 Lab 03 · Pre-Deployment Policy Verification (Batfish)

> ✅ **Validated** on Batfish 2024.1 & Python 3.11.

**Time:** ~45 minutes · **Tools:** Pybatfish, Batfish Static Analysis Engine

---

## 🧠 Technology Deep Dive: What is Batfish?

Pushing a syntax-valid configuration to a live network can still break production if an ACL blocks traffic or a routing policy leaks prefixes.

**Batfish** is an open-source network static analysis engine. It parses vendor configurations (`.cfg`), builds an offline mathematical model of the control and data plane (Abstract Syntax Tree / AST), and allows network engineers to query network behavior **BEFORE deploying code to real devices**:

```
+-------------------+      +-------------------+      +-------------------+
|  RENDERED CONFIGS |      |  BATFISH ENGINE   |      |  OFFLINE PREDICT  |
|  (rendered/*.cfg) | +===>|  Mathematical AST | +===>|  "Will host A reach|
|                   |      |  Model of Fabric  |      |   host B? YES"    |
+-------------------+      +-------------------+      +-------------------+
```

---

## 💻 Querying Batfish with Python (`pybatfish`)

```python
from pybatfish.client.session import Session

bf = Session(host="localhost")
bf.init_snapshot("labs/netdevops-lab/rendered", name="fabric-snapshot", overwrite=True)

# Query 1: Unused structures & syntax warnings
parse_status = bf.q.initIssues().answer().frame()
print(parse_status)

# Query 2: Test reachability offline without booting real routers!
reachability = bf.q.reachability(
    headers={"srcIps": "10.255.0.11", "dstIps": "10.255.0.12"}
).answer().frame()

print(reachability)
```

✅ **DONE when** Batfish verifies offline reachability between `leaf1` and `leaf2` without deploying to physical devices.
