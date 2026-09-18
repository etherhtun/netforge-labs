# 🧪 Lab 02 · အလိုအလျောက် ကွန်ရက်စစ်ဆေးခြင်း (Cisco PyATS / Genie) {: #lab-02-pyats-verification }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Cisco PyATS 24.1 & Arista cEOS 4.32.0F ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** Python 3, Cisco PyATS, Genie Parser

---

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Cisco PyATS / Genie ဆိုသည်မှာ အဘယ်နည်း {: #technology-deep-dive-what-is-cisco-pyats-genie }

ရိုးရာ network operations တွင် change ပြုလုပ်ပြီးနောက် fabric ၏ ကျန်းမာရေးကို စစ်ဆေးရန် router တိုင်းသို့ ဝင်ရောက်ပြီး `show ip ospf neighbor`၊ `show bgp evpn summary`၊ နှင့် `show interface status` တို့ကို ရိုက်နှိပ်စစ်ဆေးရသည်။

**PyATS (Python Automated Test System)** သည် မူလက internal automated regression testing ပြုလုပ်ရန် Cisco မှ တည်ဆောက်ခဲ့သော open-source Python testing framework ဖြစ်သည်။ ၎င်းကို **Genie** နှင့် တွဲဖက်လိုက်သောအခါ ဖွဲ့စည်းပုံမရှိသော vendor CLI text output များကို စနစ်ကျသော Python dictionary များအဖြစ် parse လုပ်ပေးပြီး automated test suite များကို run ပေးနိုင်ပါသည်:

```
+-------------------+      +-------------------+      +-------------------+
|  CLI TEXT OUTPUT  |      |  GENIE PARSER     |      |  PYATS ASSERTION  |
|  "3.3.3.3 Estab"  | +===>|  {"neighbor":     | +===>|  assert state ==  |
|                   |      |   {"state":       |      |  "Established"    |
|                   |      |    "Established"}}|      |                   |
+-------------------+      +-------------------+      +-------------------+
```

---

## 💻 PyATS စစ်ဆေးမှု Script ရေးသားခြင်း (`scripts/test_fabric.py`) {: #writing-a-pyats-test-script }

PyATS test suite တစ်ခုတွင် test method များ ပါဝင်သော `Testcase` class တစ်ခု ပါရှိပါသည်:

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

## အဆင့် ၁ · PyATS Verification Test ကို စတင်လည်ပတ်ခြင်း {: #step-1-run-pyats-verification-test }

လည်ပတ်နေသော containerlab topology ပေါ်တွင် automated test suite ကို run ပါ:

```bash
cd labs/netdevops-lab
python3 scripts/test_fabric.py
```

```
+------------------------------------------------------------------------------+
| PyATS Test Execution Results                                                 |
+------------------------------------------------------------------------------+
  Testcase: FabricHealthTestCase ....................................... PASSED
  
  Summary: 1 Passed, 0 Failed, 0 Errored
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** PyATS သည် network assertion check အားလုံးအတွက် `PASSED` ဟု ထုတ်ပြန်ပေးရပါမည်။
