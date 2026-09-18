# 🧪 Lab 04 · Programmatic Telemetry နှင့် State Parsing (gNMI / pygnmi) {: #lab-04-gnmi-telemetry }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - gNMI (gRPC Network Management Interface) & Python `pygnmi` ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** gNMI, Protocol Buffers (protobuf), OpenConfig YANG

---

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: gNMI vs. ရိုးရာ SNMP {: #technology-deep-dive-gnmi-vs-legacy-snmp }

ရိုးရာ network monitoring သည် `UDP 161` ပေါ်တွင် စက်ပစ္စည်းများကို အချိန်မှန် poll လုပ်ရသော **SNMP (Simple Network Management Protocol)** အပေါ်တွင် မှီခိုနေရသည်။ SNMP သည် CPU သုံးစွဲမှုများပြီး encrypt မလုပ်ထားသလို link flap များကိုလည်း လျင်မြန်စွာ မသိရှိနိုင်ပါ။

**gNMI (gRPC Network Management Interface)** သည် OpenConfig consortium မှ သတ်မှတ်ထားသော စုစည်းထားသည့် RPC protocol တစ်ခု ဖြစ်သည်:
- **Transport**: TLS ပေါ်ရှိ HTTP/2 (`TCP 6030` သို့မဟုတ် `TCP 50051`)။
- **Data Encoding**: Google Protocol Buffers (protobuf) သို့မဟုတ် JSON။
- **YANG Modeling**: OpenConfig YANG path များကို သုံးသည် (ဥပမာ `/interfaces/interface[name=Ethernet1]/state/oper-status`)။
- **Modes**: `Get`၊ `Set`၊ နှင့် `Subscribe` (streaming telemetry) တို့ကို အထောက်အပံ့ပေးသည်။

---

## 💻 Python ဖြင့် Device State ကို Query မေးမြန်းခြင်း (`pygnmi`) {: #querying-device-state-with-python }

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

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `pygnmi` သည် gRPC မှတစ်ဆင့် တိုက်ရိုက် OpenConfig interface state ကို အောင်မြင်စွာ ဆွဲယူရရှိရပါမည်။
