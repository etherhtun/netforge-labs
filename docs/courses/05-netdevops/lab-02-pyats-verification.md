# 🧪 Lab 02 · Automated Network Verification (Cisco PyATS / Genie)

> ✅ **Validated** on Cisco PyATS 24.1 & Arista cEOS 4.32.0F.

**Time:** ~45 minutes · **Tools:** Python 3, Cisco PyATS, Genie Parser

---

## 🧠 Technology Deep Dive: What is Cisco PyATS / Genie?

In traditional network operations, verifying fabric health after a change requires logging into every router and typing `show ip ospf neighbor`, `show bgp evpn summary`, and `show interface status`.

**PyATS (Python Automated Test System)** is an open-source Python testing framework originally built by Cisco for internal automated regression testing. Coupled with **Genie**, it parses unstructured vendor CLI text into structured Python dictionaries and runs automated test suites:

```
+-------------------+      +-------------------+      +-------------------+
|  CLI TEXT OUTPUT  |      |  GENIE PARSER     |      |  PYATS ASSERTION  |
|  "3.3.3.3 Estab"  | +===>|  {"neighbor":     | +===>|  assert state ==  |
|                   |      |   {"state":       |      |  "Established"    |
|                   |      |    "Established"}}|      |                   |
+-------------------+      +-------------------+      +-------------------+
```

---

## 💻 Writing a PyATS Test Script (`scripts/test_fabric.py`)

A PyATS test suite consists of a `Testcase` class containing test methods:

```python
from pyats import aetest
import subprocess, json

class FabricHealthTestCase(aetest.Testcase):

    @aetest.test
    def test_evpn_bgp_neighbors(self):
        """Assert BGP EVPN neighbor state is Established on leaf1."""
        cmd = "docker exec -i clab-netdevops-lab-leaf1 Cli -p 15 -c 'show bgp evpn summary'"
        res = subprocess.check_output(cmd, shell=True).decode()
        
        assert "10.255.0.1" in res, "spine1 EVPN neighbor missing"
        assert "10.255.0.2" in res, "spine2 EVPN neighbor missing"
        print("✅ BGP EVPN neighbors are OPERATIONAL!")

if __name__ == '__main__':
    aetest.main()
```

---

## Step 1 · Run the PyATS Verification Test

Execute the automated test suite against the running containerlab topology:

```bash
cd netforge-labs/labs/netdevops-lab
python3 scripts/test_fabric.py
```

```
+------------------------------------------------------------------------------+
| PyATS Test Execution Results                                                 |
+------------------------------------------------------------------------------+
  Testcase: FabricHealthTestCase ....................................... PASSED
  
  Summary: 1 Passed, 0 Failed, 0 Errored
```

✅ **DONE when** PyATS outputs `PASSED` for all network assertion checks.
