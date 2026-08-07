# 🧪 Lab 01 · Data-Driven Config Generation (Jinja2 & YAML)

> ✅ **Validated** on Arista cEOS 4.32.0F & Python 3.11.

**Time:** ~40 minutes · **Tools:** Python 3, PyYAML, Jinja2

!!! tip "Hybrid Approach — Script Push or Manual Typing"
    Every lab supports both automated execution and manual line-by-line configuration:

    - **Option A · Automated Script Push (Fast & Error-Free)**:
      ```bash
      cd netforge-labs/labs/netdevops-lab
      ./run.sh --all       # render, push, and verify automatically
      ```
    - **Option B · Hands-on Python Script Execution**:
      ```bash
      python3 labs/netdevops-lab/scripts/generate_configs.py
      ```

---

## 🚀 Getting Started & Repository Setup

Before starting Lab 01, clone the repository (or run `git pull` if already cloned) and set up your Python environment:

```bash
# 1. Clone repository (or pull latest changes)
git clone https://github.com/etherhtun/netforge-labs.git
cd netforge-labs

# 2. Set up Python virtual environment & install dependencies
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 3. Enter the NetDevOps lab directory
cd labs/netdevops-lab
```

---

## 🧠 Technology Deep Dive: Separating Data from Logic

In traditional network engineering, device hostname, IP addresses, and routing parameters are hardcoded directly into vendor CLI strings. If you need to change an OSPF area ID across 100 leaf switches, you have to edit 100 individual configuration files!

In **NetDevOps**, we separate **Data** from **Templates**:

```
+-------------------+      +-------------------+      +-------------------+
|  DATA MODEL       |      |  JINJA2 TEMPLATE  |      |  RENDERED OUTPUT  |
|  (data/hosts.yaml)| +===>|  (templates/*.j2) | +===>|  (rendered/*.cfg) |
|  Raw IP parameters|      |  CLI Structure    |      |  Valid Vendor CLI |
+-------------------+      +-------------------+      +-------------------+
```

---

### 1. YAML Data Model Breakdown (`data/hosts.yaml`)
**YAML** (YAML Ain't Markup Language) stores structured network data using simple key-value pairs (`key: value`), lists (`- item`), and nested dictionaries:

```yaml
fabric:
  name: NetForge-DC1
  asn: 65000
  ospf_area: 0.0.0.0

spines:
  - name: spine1
    mgmt_ip: 172.20.20.31
    router_id: 10.255.0.1
    interfaces:
      - name: Ethernet1
        ip: 10.0.1.1/30
        neighbor: leaf1
```

- `fabric`: Global network variables (ASN `65000`, OSPF Area `0.0.0.0`).
- `spines`: A list (`-`) of spine router dictionaries containing interface arrays.

---

### 2. Jinja2 Template Breakdown (`templates/spine.j2`)
**Jinja2** is a templating engine for Python that dynamically generates text files:
- **`{{ variable }}`**: Inserts a data value (e.g. `{{ node.name }}` $\rightarrow$ `spine1`).
- **`{% for item in list %}`**: Loops through an array of interfaces.

```jinja2
configure
hostname {{ node.name }}
!
interface Loopback0
   ip address {{ node.router_id }}/32
   ip ospf area {{ fabric.ospf_area }}
!
{% for intf in node.interfaces %}
interface {{ intf.name }}
   no switchport
   ip address {{ intf.ip }}
   ip ospf area {{ fabric.ospf_area }}
!
{% endfor %}
```

---

### 3. Python Rendering Script (`scripts/generate_configs.py`)
Python reads the YAML file, passes data to Jinja2, and saves the generated `.cfg` files:

```python
import os, yaml
from jinja2 import Environment, FileSystemLoader

with open("data/hosts.yaml", "r") as f:
    data = yaml.safe_load(f)

env = Environment(loader=FileSystemLoader("templates"))
template = env.get_template("spine.j2")

for spine in data["spines"]:
    rendered = template.render(node=spine, fabric=data["fabric"])
    with open(f"rendered/{spine['name']}.cfg", "w") as f:
        f.write(rendered)
```

---

## Step 1 · Generate Configurations

Run the Jinja2 generator script to produce device configurations:

```bash
cd netforge-labs/labs/netdevops-lab
python3 scripts/generate_configs.py
```

```
Rendered: labs/netdevops-lab/rendered/spine1.cfg
Rendered: labs/netdevops-lab/rendered/spine2.cfg
Rendered: labs/netdevops-lab/rendered/leaf1.cfg
Rendered: labs/netdevops-lab/rendered/leaf2.cfg
✅ Configuration rendering complete!
```

---

## Step 2 · Inspect Rendered Output (`rendered/spine1.cfg`)

Verify that Jinja2 generated a 100% valid EOS configuration:

```eos
configure
hostname spine1
!
interface Loopback0
   ip address 10.255.0.1/32
   ip ospf area 0.0.0.0
!
interface Ethernet1
   no switchport
   ip address 10.0.1.1/30
   ip ospf area 0.0.0.0
!
interface Ethernet2
   no switchport
   ip address 10.0.1.5/30
   ip ospf area 0.0.0.0
!
router ospf 100
   router-id 10.255.0.1
   passive-interface Loopback0
```

✅ **DONE when** `rendered/spine1.cfg` contains valid EOS commands generated from `hosts.yaml`.
