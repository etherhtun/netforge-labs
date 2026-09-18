# 🧪 Lab 03 · Deploy မတိုင်မီ မူဝါဒစစ်ဆေးခြင်း (Batfish) {: #lab-03-batfish-simulation }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Batfish 2024.1 & Python 3.11 ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** Pybatfish, Batfish Static Analysis Engine

---

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Batfish ဆိုသည်မှာ အဘယ်နည်း {: #technology-deep-dive-what-is-batfish }

Syntax မှန်ကန်သော configuration တစ်ခုကို တကယ့် live network ပေါ်သို့ push လုပ်လိုက်သော်လည်း ACL က traffic ကို ပိတ်ပင်လိုက်ခြင်း သို့မဟုတ် routing policy မှ prefix များ leak ဖြစ်သွားခြင်းတို့ကြောင့် production ကို ပျက်စီးသွားစေနိုင်သည်။

**Batfish** သည် open-source network static analysis engine တစ်ခု ဖြစ်သည်။ ၎င်းသည် vendor configuration (`.cfg`) ဖိုင်များကို ဖတ်ရှုပြီး control plane နှင့် data plane ၏ offline သင်္ချာဆိုင်ရာ ပုံစံတူ (Abstract Syntax Tree / AST) ကို တည်ဆောက်ပေးကာ၊ ကွန်ရက် အင်ဂျင်နီယာများအား **တကယ့် device များပေါ်သို့ code မ deploy မီ** ကွန်ရက်၏ အပြုအမူကို ကြိုတင် query မေးမြန်းခွင့် ပေးပါသည်:

```
+-------------------+      +-------------------+      +-------------------+
|  RENDERED CONFIGS |      |  BATFISH ENGINE   |      |  OFFLINE PREDICT  |
|  (rendered/*.cfg) | +===>|  Mathematical AST | +===>|  "Will host A reach|
|                   |      |  Model of Fabric  |      |   host B? YES"    |
+-------------------+      +-------------------+      +-------------------+
```

---

## 💻 Python ဖြင့် Batfish ကို Query မေးမြန်းခြင်း (`pybatfish`) {: #querying-batfish-with-python }

```python
from pybatfish.client.session import Session

bf = Session(host="localhost")
bf.init_snapshot("labs/netdevops-lab/rendered", name="fabric-snapshot", overwrite=True)

# Query 1: အသုံးမပြုသော ဖွဲ့စည်းပုံများနှင့် syntax သတိပေးချက်များ
parse_status = bf.q.initIssues().answer().frame()
print(parse_status)

# Query 2: တကယ့် router များကို boot တက်စရာမလိုဘဲ offline reachability စမ်းသပ်ခြင်း!
reachability = bf.q.reachability(
    headers={"srcIps": "10.255.0.11", "dstIps": "10.255.0.12"}
).answer().frame()

print(reachability)
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** Batfish သည် physical device များပေါ်သို့ မ deploy မီ `leaf1` နှင့် `leaf2` အကြား offline reachability ကို အောင်မြင်စွာ စစ်ဆေးအတည်ပြုပေးရပါမည်။
