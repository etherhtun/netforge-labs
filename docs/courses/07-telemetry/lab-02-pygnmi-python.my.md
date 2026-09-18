# 🧪 Lab 02 · pygnmi နှင့် Python ဖြင့် တိုက်ရိုက် Telemetry Data ရယူခြင်း {: #lab-02-pygnmi-python }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Python 3.11 & `pygnmi` ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** Python 3, pygnmi library

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/telemetry-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/telemetry-lab
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
          docker exec -it clab-telemetry-lab-leaf1 Cli
          ```

---
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Python gNMI Client (`pygnmi`) {: #technology-deep-dive-python-gnmi-client }

Python `pygnmi` သည် network engineer များအား gRPC ပေါ်မှ တိုက်ရိုက် streaming gNMI telemetry data များကို query ပြုလုပ်ပြီး စနစ်ကျသော JSON dictionary များအဖြစ် ထုတ်ယူနိုင်စေပါသည်:

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

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `pygnmi` သည် gRPC မှတစ်ဆင့် တိုက်ရိုက် interface counter များကို JSON format ဖြင့် အောင်မြင်စွာ ဆွဲယူရရှိရပါမည်။
