# 🧪 Lab 05 · အလိုအလျောက် Telemetry Alerting နှင့် ပုံမှန်မဟုတ်မှုများ ရှာဖွေခြင်း {: #lab-05-telemetry-alerting }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Prometheus Alertmanager ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** Alertmanager

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
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: အလိုအလျောက် ကွန်ရက် အသိပေးစနစ် (Alerting) {: #technology-deep-dive-automated-network-alerting }

Prometheus Alertmanager သည် streaming telemetry rule များကို ၅ စက္ကန့်တိုင်း စစ်ဆေးအကဲဖြတ်သည်။ အကယ်၍ interface တစ်ခုကျသွားခြင်း သို့မဟုတ် BGP neighbor flap ဖြစ်သွားပါက alert တစ်ခုကို ချက်ချင်း အစပျိုးပေးပါသည်:

```yaml
groups:
  - name: network_alerts
    rules:
      - alert: BGPNeighborDown
        expr: openconfig_bgp_neighbor_state_session_state != 1
        for: 10s
        labels:
          severity: critical
        annotations:
          summary: "BGP Session Down on {{ $labels.instance }}"
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** Interface `Ethernet1` အား ပိတ်လိုက်ခြင်း (shutdown) သည် ချက်ချင်း `BGPNeighborDown` firing alert တစ်ခုကို ဖြစ်ပေါ်စေရပါမည်။
