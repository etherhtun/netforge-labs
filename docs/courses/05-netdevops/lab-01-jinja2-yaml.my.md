# 🧪 Lab 01 · Data-Driven Config ဖန်တီးထုတ်လုပ်ခြင်း (Jinja2 & YAML) {: #lab-01-jinja2-yaml }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F & Python 3.11 ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၀ မိနစ် · **ကိရိယာများ:** Python 3, PyYAML, Jinja2

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/netdevops-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/netdevops-lab
    sudo containerlab deploy -t topology.clab.yml --max-workers 1
    ```

    **အဆင့် ၂ · အပြန်အလှန် Interactive လမ်းညွှန်ကို စတင်ပါ**
    ```bash
    ./run.sh --guided
    ```

    ??? note "အခြား Run နိုင်သော နည်းလမ်းများ (Automated Script သို့မဟုတ် Manual CLI)"
        - **Fast Automated Script Push**:
          ```bash
          ./run.sh 01          # step 01 ကို အလိုအလျောက် config ထည့်သွင်း၍ စစ်ဆေးမည်
          ./run.sh --all       # အဆင့်အားလုံးကို အစီအစဉ်အတိုင်း run မည်
          ```
        - **Manual Line-by-Line CLI Execution**:
          Container node တစ်ခုချင်းစီသို့ CLI shell ဝင်ရောက်ရန်:
          ```bash
          docker exec -it clab-netdevops-lab-node1 Cli
          ```

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Data နှင့် Logic ကို သီးခြားခွဲထုတ်ခြင်း {: #technology-deep-dive-separating-data-from-logic }

ရိုးရာ network engineering တွင် device hostname၊ IP address၊ နှင့် routing parameter များကို vendor CLI စာသားများထဲသို့ တိုက်ရိုက် ရေးသွင်းလေ့ရှိကြသည်။ အကယ်၍ leaf switch အလုံး ၁၀၀ ပေါ်တွင် OSPF area ID ကို ပြောင်းလဲရန် လိုအပ်ပါက configuration ဖိုင်ပေါင်း ၁၀၀ ကို တစ်ခုချင်းစီ လိုက်လံပြင်ဆင်ရမည် ဖြစ်သည်!

**NetDevOps** တွင် ကျွန်ုပ်တို့သည် **Data** နှင့် **Templates** ကို သီးခြားခွဲထုတ်ပါသည်:

```
+-------------------+      +-------------------+      +-------------------+
|  DATA MODEL       |      |  JINJA2 TEMPLATE  |      |  RENDERED OUTPUT  |
|  (data/hosts.yaml)| +===>|  (templates/*.j2) | +===>|  (rendered/*.cfg) |
|  Raw IP parameters|      |  CLI Structure    |      |  Valid Vendor CLI |
+-------------------+      +-------------------+      +-------------------+
```

---

### ၁။ YAML Data Model ဖွဲ့စည်းပုံ (`data/hosts.yaml`) {: #1-yaml-data-model-breakdown }
**YAML** (YAML Ain't Markup Language) သည် စနစ်ကျသော network data များကို key-value pairs (`key: value`)၊ lists (`- item`)၊ နှင့် nested dictionaries များဖြင့် သိမ်းဆည်းပေးပါသည်:

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

- `fabric`: တစ်ကမ္ဘာလုံးဆိုင်ရာ global network variable များ (ASN `65000`, OSPF Area `0.0.0.0`)။
- `spines`: Interface array များ ပါဝင်သော spine router dictionary များ၏ list (`-`)။

---

### ၂။ Jinja2 Template ဖွဲ့စည်းပုံ (`templates/spine.j2`) {: #2-jinja2-template-breakdown }
**Jinja2** သည် text file များကို dynamic နည်းဖြင့် ဖန်တီးပေးသော Python templating engine ဖြစ်ပါသည်:
- **`{{ variable }}`**: Data တန်ဖိုးတစ်ခုကို ထည့်သွင်းပေးသည် (ဥပမာ `{{ node.name }}` → `spine1`)။
- **`{% for item in list %}`**: Interface array တစ်ခုကို loop ပတ်၍ ထုတ်ပေးသည်။

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

### ၃။ Python Rendering Script (`scripts/generate_configs.py`) {: #3-python-rendering-script }
Python သည် YAML ဖိုင်ကို ဖတ်ရှုပြီး Jinja2 ထံ data များ ပေးပို့ကာ ထွက်ပေါ်လာသော `.cfg` ဖိုင်များကို သိမ်းဆည်းပေးပါသည်:

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

## အဆင့် ၁ · Configuration များကို ထုတ်လုပ်ဖန်တီးခြင်း {: #step-1-generate-configurations }

Device configuration များကို ဖန်တီးရန် Jinja2 generator script ကို run ပါ:

```bash
cd labs/netdevops-lab
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

## အဆင့် ၂ · ထွက်ပေါ်လာသော Output ကို စစ်ဆေးခြင်း (`rendered/spine1.cfg`) {: #step-2-inspect-rendered-output }

Jinja2 သည် 100% မှန်ကန်သော EOS configuration ကို ထုတ်လုပ်ပေးထားခြင်း ရှိမရှိ စစ်ဆေးပါ:

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

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `rendered/spine1.cfg` တွင် `hosts.yaml` မှ ထုတ်လုပ်ထားသော မှန်ကန်သည့် EOS command များ ပါဝင်နေရပါမည်။
