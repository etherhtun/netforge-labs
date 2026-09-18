# 🧪 Lab 02 · VRF Microsegmentation နှင့် Inter-VRF Route Leaking {: #lab-02-vrf-route-leaking-acls }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** VRF Isolation, Route Maps, IP Access Lists

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/security-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/security-lab
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
          docker exec -it clab-security-lab-leaf1 Cli
          ```

---
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: VRF Microsegmentation {: #technology-deep-dive-vrf-microsegmentation }

Multi-tenant data center များသည် မတူညီသော customer ဌာနများကို (`VRF-TENANT-A`, `VRF-TENANT-B`) သီးခြား routing table များထဲသို့ သီးသန့်ခွဲထုတ်ထားသည်။ Tenant workload များသည် မျှဝေသုံးစွဲထားသော management service (`VRF-SHARED-SERVICES`) ဆီသို့ ထိန်းချုပ်ထားသည့် ဆက်သွယ်မှု လိုအပ်လာသောအခါ တင်းကျပ်သော IP access-list များဖြင့် inter-VRF route leaking ကို ချိန်ညှိပြင်ဆင်ပေးရပါသည်:

```eos
vrf instance VRF-TENANT-A
!
ip route vrf VRF-TENANT-A 10.100.0.0/16 vrf VRF-SHARED-SERVICES
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `show ip route vrf VRF-TENANT-A` တွင် `VRF-TENANT-B` ဆီသို့ ဘေးတိုက် traffic များကို ပိတ်ပင်ထားစဉ် မျှဝေသုံးစွဲထားသော shared service subnet များကိုသာ သီးသန့်ခွင့်ပြုထားကြောင်း တွေ့မြင်ရမည် ဖြစ်သည်။
