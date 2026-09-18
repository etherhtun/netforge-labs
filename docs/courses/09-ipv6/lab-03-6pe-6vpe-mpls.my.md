# 🧪 Lab 03 · 6PE နှင့် 6VPE (MPLS Backbones ပေါ်တွင် IPv6 အသုံးပြုခြင်း RFC 4659) {: #lab-03-6pe-6vpe-mpls }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** 6PE, 6VPE, MP-BGP Label Exchange

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/ipv6-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/ipv6-lab
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
          docker exec -it clab-ipv6-lab-leaf1-v6 Cli
          ```

---
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: 6PE & 6VPE လုပ်ဆောင်ချက်များ {: #technology-deep-dive-6pe-6vpe-mechanics }

Core service provider MPLS ကွန်ရက်တစ်ခုအား native IPv6 သို့ အဆင့်မြှင့်တင်ခြင်းသည် ကုန်ကျစရိတ်ကြီးမားပြီး ရှုပ်ထွေးလှပါသည်။

- **6PE (IPv6 Provider Edge)**: Provider Edge (PE) router များအား MP-BGP (`AFI 2 / SAFI 1`) မှတစ်ဆင့် IPv6 prefix နှင့် MPLS label ကို ချိတ်ဆက်ပေးခြင်းဖြင့် IPv4-only MPLS core ပေါ်တွင် IPv6 global prefix များကို ဖြတ်သန်းသယ်ဆောင်နိုင်စေပါသည်။
- **6VPE**: Multi-tenant IPv6 L3VPN isolation (`AFI 2 / SAFI 128`) ကို ပေးစွမ်းနိုင်ရန် 6PE ကို တိုးချဲ့ထားခြင်း ဖြစ်သည်။

```eos
router bgp 65000
   address-family ipv6
      neighbor 10.255.0.2 activate
      neighbor 10.255.0.2 send-community standard extended
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `show bgp ipv6 unicast` တွင် 6PE 2-label stacks (`Transport Label` + `IPv6 Service Label`) ကို အောင်မြင်စွာ တွေ့မြင်ရမည် ဖြစ်သည်။
