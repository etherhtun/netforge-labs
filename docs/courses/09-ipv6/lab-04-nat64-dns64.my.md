# 🧪 Lab 04 · Stateful NAT64 နှင့် DNS64 Translation လုပ်ဆောင်ချက်များ {: #lab-04-nat64-dns64 }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - NAT64 / DNS64 specification (RFC 6146) ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** Stateful NAT64, DNS64 Synthetic AAAA

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
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: NAT64 & DNS64 Translation {: #technology-deep-dive-nat64-dns64-translation }

IPv6-only endpoint များသည် (`2001:db8::100`) IPv4 နှင့် IPv6 packet header များ ကိုက်ညီမှုမရှိသောကြောင့် ရိုးရာ IPv4 server များနှင့် (`192.0.2.50`) တိုက်ရိုက် ဆက်သွယ်၍ မရနိုင်ပါ။

- **DNS64**: Well-Known Prefix (`64:ff9b::/96`) ကို အသုံးပြု၍ IPv4-only domain များအတွက် IPv6 `AAAA` record များကို ဖန်တီး (synthesize) ပေးသည်။
- **Stateful NAT64**: ဦးတည်လိပ်စာ `64:ff9b::192.0.2.50` ပါရှိသော IPv6 packet များကို ဦးတည်လိပ်စာ `192.0.2.50` ပါရှိသော IPv4 packet များအဖြစ် ပြောင်းလဲပေးသည်။

```eos
ip nat64 prefix 64:ff9b::/96
ip nat64 pool NAT64-POOL 198.51.100.100 198.51.100.110
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** IPv6-only host သည် synthetic `64:ff9b::` prefix မှတစ်ဆင့် IPv4 service ကို အောင်မြင်စွာ ping နိုင်ရပါမည်။
