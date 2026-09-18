# 🧪 Lab 03 · BFD ဖြင့် စက္ကန့်ပိုင်းအတွင်း WAN Link Failover ပြုလုပ်ခြင်း {: #lab-03-bfd-subsecond-failover }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F BFD engine ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** BFD (Bidirectional Forwarding Detection)

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
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: BFD vs. သမားရိုးကျ BGP Timers {: #technology-deep-dive-bfd-vs-standard-bgp-timers }

သမားရိုးကျ BGP သည် 60-second Keepalive နှင့် 180-second Hold-Timer ကို အသုံးပြုသည်။ အကယ်၍ ကြားခံ fiber ကြိုး ပြတ်တောက်သွားသော်လည်း interface link down signal မပြပါက BGP သည် ချို့ယွင်းမှုကို သိရှိနိုင်ရန် ၃ မိနစ်အထိ ကြာမြင့်နိုင်ပါသည်!

**BFD (Bidirectional Forwarding Detection)** သည် စက္ကန့်ပိုင်းမပြည့်သော အချိန်တိုအတွင်း (sub-second intervals) micro-hello control packet များကို အပြန်အလှန် ပေးပို့စစ်ဆေးပေးပါသည် (ဥပမာ 300ms intervals ဖြင့် multiplier 3 သတ်မှတ်ပါက → 900ms အတွင်း ချို့ယွင်းမှုကို သိရှိနိုင်သည်):

```eos
interface Ethernet1
   bfd interval 300 min_rx 300 multiplier 3
!
router bgp 65000
   neighbor 198.51.100.2 fall-over bfd
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `show bfd neighbors` တွင် 300ms timers ဖြင့် တက်ကြွနေသော BFD session အား `Up` အခြေအနေအဖြစ် ပြသရပါမည်။
