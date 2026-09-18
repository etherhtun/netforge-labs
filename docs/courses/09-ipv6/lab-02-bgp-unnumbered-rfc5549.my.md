# 🧪 Lab 02 · BGP Unnumbered (BGP over IPv6 Link-Local RFC 5549) {: #lab-02-bgp-unnumbered-rfc5549 }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** BGP Unnumbered, Extended Next Hop (RFC 5549 / RFC 8950)

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
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: BGP Unnumbered (RFC 5549 / RFC 8950) {: #technology-deep-dive-bgp-unnumbered }

သမားရိုးကျ BGP topology များတွင် point-to-point interface တိုင်းသည် IP address သတ်မှတ်ပေးရန် လိုအပ်သည် (IPv4 တွင် `/30` သို့မဟုတ် `/31`၊ IPv6 တွင် `/64` သို့မဟုတ် `/127`)။

**BGP Unnumbered** သည် eBGP session များ တည်ဆောက်ရန်အတွက် EUI-64 မှတစ်ဆင့် အလိုအလျောက် ထုတ်ပေးသော IPv6 Link-Local address များကို (`fe80::/10`) အသုံးပြုသည်။ RFC 5549 / RFC 8950 သည် BGP ကို တိုးချဲ့ပေးသောကြောင့် **IPv4 နှင့် IPv6 prefix များကို IPv6-only link-local transport ပေါ်တွင် ကြေညာနိုင်စေပါသည်**:

```eos
interface Ethernet1
   ipv6 enable
!
router bgp 65000
   neighbor Ethernet1 interface remote-as 65001
   !
   address-family ipv4
      neighbor Ethernet1 activate
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `show bgp summary` တွင် IPv6 Link-Local address များမှတစ်ဆင့် interface `Ethernet1` ပေါ်၌ BGP session များ အောင်မြင်စွာ တည်ဆောက်ထားကြောင်း ပြသရပါမည်။
