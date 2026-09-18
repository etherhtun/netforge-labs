# 🧪 Lab 03 · Streaming Telemetry Collectors နှင့် Prometheus Metrics {: #lab-03-prometheus-time-series }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Prometheus 2.50 ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** Prometheus, gNMI Exporter

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
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Time-Series ဒေတာ စုဆောင်းခြင်း {: #technology-deep-dive-time-series-data-collection }

**Prometheus** သည် metric name များနှင့် key-value pairs (labels) များဖြင့် သတ်မှတ်ထားသော time-series metric data များကို သိမ်းဆည်းပေးပါသည်။ gNMI Exporter သည် cEOS node များထံမှ gNMI stream များကို subscribe လုပ်ပြီး Prometheus scrape ပြုလုပ်နိုင်ရန် `http://localhost:9090/metrics` ပေါ်တွင် ထုတ်ပေးထားပါသည်:

```yaml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: 'ceos-gnmi'
    static_configs:
      - targets: ['172.20.20.41:6030', '172.20.20.43:6030']
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** Prometheus status targets စာမျက်နှာ (`http://localhost:9090/targets`) တွင် cEOS node အားလုံးသည် `UP` အခြေအနေအဖြစ် ပြသရပါမည်။
