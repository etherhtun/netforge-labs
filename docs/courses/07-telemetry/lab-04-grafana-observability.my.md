# 🧪 Lab 04 · Real-Time Visual Grafana Network Dashboards {: #lab-04-grafana-observability }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Grafana 10.3 ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** Grafana Dashboard

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
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Network Observability Dashboards {: #technology-deep-dive-network-observability-dashboards }

**Grafana** သည် network throughput၊ BGP neighbor state၊ နှင့် interface error များကို real-time dashboard များအဖြစ် ဖော်ပြပေးရန် Prometheus time-series data နှင့် ချိတ်ဆက်ပေးပါသည်:

- **Interface Throughput (bits/sec)**:
  `rate(openconfig_interfaces_interface_state_counters_in_octets[1m]) * 8`
- **BGP Peer State (Established = 1)**:
  `openconfig_bgp_neighbor_state_session_state == 1`

Local dashboard သို့ `http://localhost:3000` မှတစ်ဆင့် ဝင်ရောက်ကြည့်ရှုနိုင်ပါသည်။

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** Grafana သည် cEOS interface များအတွက် real-time throughput graph များကို အောင်မြင်စွာ ရေးဆွဲပြသရပါမည်။
