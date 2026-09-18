# 🧪 Lab 03 · Infrastructure ACLs (iACLs) နှင့် Core ကာကွယ်မှု {: #lab-03-infrastructure-acls }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် စမ်းသပ်ထားပါသည်။

**ကြာချိန်:** ~၄၅ မိနစ် · **ကိရိယာများ:** Infrastructure ACLs (iACLs)

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
## 🧠 နည်းပညာ အတွင်းကျကျ လေ့လာမှု: Infrastructure Protection ACLs {: #technology-deep-dive-infrastructure-protection-acls }

**Infrastructure Access Control Lists (iACLs)** သည် core router loopback address များ (`10.255.0.0/16`) နှင့် point-to-point transit interface များကို (`10.0.0.0/16`) ခွင့်ပြုချက်မရှိဘဲ ပြင်ပမှ scanning ဖတ်ရှုခြင်းနှင့် IP spoofing တိုက်ခိုက်မှုများမှ ကာကွယ်ပေးပါသည်:

```eos
ip access-list ACL-INFRASTRUCTURE-PROTECT
   10 permit ospf 10.0.0.0/16 10.0.0.0/16
   20 permit tcp 172.20.20.0/24 10.255.0.0/16 eq ssh
   30 deny ip any 10.255.0.0/16 log
   40 permit ip any any
!
interface Ethernet1
   ip access-group ACL-INFRASTRUCTURE-PROTECT in
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `show ip access-lists ACL-INFRASTRUCTURE-PROTECT` တွင် loopback IP block များကို ဦးတည်လာသော ခွင့်ပြုချက်မရှိသည့် အဝင် traffic များကို ပယ်ချ (drop) ထားသည့် log များကို မှန်ကန်စွာ တွေ့မြင်ရမည် ဖြစ်သည်။
