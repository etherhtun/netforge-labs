# 🧪 Lab 04 · Local RPKI Route Origin Validation (ROV) {: #lab-04-rpki-route-validation }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - RPKI / ROA Validation logic ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** RPKI, ROA (Route Origin Authorization)

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/wan-edge-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/wan-edge-lab
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
          docker exec -it clab-wan-edge-lab-wan-edge1 Cli
          ```

---
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: RPKI Route Origin Validation {: #technology-deep-dive-rpki-route-origin-validation }

BGP route hijacking သည် အခွင့်မရှိသော Autonomous System တစ်ခုက အခြားအဖွဲ့အစည်းတစ်ခုပိုင်ဆိုင်သည့် prefix များကို ကြေညာမိသည့်အခါ ဖြစ်ပွားတတ်သည်။ **RPKI (Resource Public Key Infrastructure)** သည် cryptographic digital sign ပြုလုပ်ထားသော ROA object များကို အသုံးပြု၍ origin AS သည် အဆိုပါ prefix အား ကြေညာခွင့်ရှိမရှိ စစ်ဆေးအတည်ပြုပေးပါသည်:

- **Valid**: Origin AS သည် ROA မှတ်တမ်းနှင့် ကိုက်ညီသည် → Route အား လက်ခံသည်။
- **Invalid**: Origin AS သည် ROA မှတ်တမ်းနှင့် မကိုက်ညီပါ → Route အား ချက်ချင်း ပယ်ချ (drop) ပစ်သည်။
- **NotFound**: မည်သည့် ROA မှတ်တမ်းမှ မရှိပါ → ဦးစားပေးအဆင့် လျှော့ချ၍ လက်ခံသည်။

```eos
router bgp 65000
   rpki cache local-validator
      host 172.20.20.1 port 3323
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `show bgp rpki status` တွင် တက်ကြွနေသော RPKI validation session များကို အောင်မြင်စွာ ပြသရပါမည်။
