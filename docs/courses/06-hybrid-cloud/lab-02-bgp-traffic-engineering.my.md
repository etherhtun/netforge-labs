# 🧪 Lab 02 · Inbound နှင့် Outbound BGP Traffic Engineering {: #lab-02-bgp-traffic-engineering }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** Route Maps, AS-PATH Prepending, BGP Communities

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

## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Dual ISPs အကြား Traffic ကို လမ်းကြောင်းထိန်းကျောင်းခြင်း {: #technology-deep-dive-steering-traffic-across-dual-isps }

ISP နှစ်ခုနှင့် multihomed ချိတ်ဆက်ထားသောအခါ BGP path selection သည် outbound နှင့် inbound traffic မည်သို့ စီးဆင်းမည်ကို ဆုံးဖြတ်ပေးပါသည်:

### ၁။ အထွက်လမ်းကြောင်း ထိန်းချုပ်ခြင်း (Outbound Traffic Control via `LOCAL_PREF`) {: #1-outbound-traffic-control }
`LOCAL_PREF` သည် `wan-edge1` နှင့် `wan-edge2` အကြား ပေးပို့သည့် iBGP-only attribute တစ်ခု ဖြစ်သည်။ ပိုကြီးသော `LOCAL_PREF` တန်ဖိုးက အနိုင်ရရှိသည်:
- Primary ISP A (`198.51.100.2`): `LOCAL_PREF 200` (ဦးစားပေး အသုံးပြုသည်)
- Backup ISP B (`203.0.113.2`): `LOCAL_PREF 100`

---

### ၂။ အဝင်လမ်းကြောင်း ထိန်းချုပ်ခြင်း (Inbound Traffic Control via AS-PATH Prepending) {: #2-inbound-traffic-control }
ပြင်ပကွန်ရက်များမှ အဝင် traffic များအတွက် Primary ISP A ကို မဖြစ်မနေ ဦးစားပေး ရွေးချယ်စေရန်အတွက် `wan-edge2` သည် Backup ISP B ဘက်သို့ မိမိ၏ Autonomous System number ကို အကြိမ်ကြိမ် ရှေ့တွင် ထပ်ဆင့်ဖြည့်စွက် (prepend) ကြေညာပေးပါသည် (`65000 65000 65000`):

```eos
route-map PREPEND-OUT permit 10
   set as-path prepend 65000 65000 65000
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** ပြင်ပကွန်ရက်များပေါ်ရှိ `show ip route bgp` တွင် ပိုမိုတိုတောင်းသော AS-PATH အလျားကြောင့် Primary ISP A ကို ဦးစားပေးအဖြစ် တွေ့မြင်ရမည် ဖြစ်သည်။
