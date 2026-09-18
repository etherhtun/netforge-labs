# အခြေခံအုတ်မြစ်များ — Linux & Physical Infrastructure

> 📖 **သဘောတရားဖတ်ရှုရန်။** Command တိုင်းကို သင့်လက်ရှိ lab host ပေါ်တွင် တိုက်ရိုက် run နိုင်ပါသည်။

သင့်အား Linux server အုပ်ချုပ်သူ (admin) လုပ်ခိုင်းမည် မဟုတ်ပါ။ သို့သော် routers ၄၀ ပေါ်ရှိ BGP အခြေအနေကို စစ်ဆေးခိုင်းခြင်း၊ စက်အားလုံးမှ config ကို ဆွဲထုတ်ခိုင်းခြင်း၊ ပြီးခဲ့သည့်အပတ်နှင့် ယနေ့ config ကို နှိုင်းယှဉ် diff လုပ်ခိုင်းခြင်း၊ နှင့် automation job က မနက် ၃ နာရီတွင် အဘယ်ကြောင့် fail ဖြစ်သွားသည်ကို ရှင်းပြခိုင်းခြင်းများ **သေချာပေါက် ကြုံတွေ့ရပါမည်**။

၎င်းတို့သည် ဤသင်ရိုးက လွှမ်းခြုံထားသော အကြောင်းအရာများ ဖြစ်ပါသည်: ကွန်ရက်အင်ဂျင်နီယာတစ်ဦး အမှန်တကယ် အသုံးပြုရမည့် Linux စွမ်းရည်များ။

---

## ယခင်ထက် အဘယ်ကြောင့် ပို၍ အရေးပါလာသနည်း

| ယခင်က | ယနေ့ခေတ် |
|---|---|
| စက်ထဲ login ဝင်၊ commands ရိုက် | စက် ၅၀ ပေါ် script ဖြင့် တစ်ပြိုင်နက် run |
| Config သည် စက်ပစ္စည်းပေါ်တွင်သာ ရှိသည် | Config သည် **git** ထဲတွင် ရှိသည် |
| `show` output ကို မျက်စိဖြင့် ဖတ်သည် | Output ကို **parse လုပ်**၊ diff စစ်၊ alert ထုတ်သည် |
| Vendor CLI သာ သုံးသည် | Vendor CLI အပြင် **HTTP ပေါ်မှ REST/gNMI** ပါ သုံးသည် |
| Manual change window စောင့်သည် | Fail ဖြစ်ပါက debug လုပ်ရမည့် CI pipeline ကို သုံးသည် |

ညာဘက်ကော်လံရှိ အရာတိုင်းသည် Linux စွမ်းရည်များ ဖြစ်ကြပါသည်။ အဆိုပါ စွမ်းရည်များကို မျှော်လင့်ထားသော အင်တာဗျူးများကို ဖြေဆိုအောင်မြင်ရန်လည်း ဖြစ်ပါသည်။

---

## သင်ယူလေ့လာရမည့် အကြောင်းအရာများ

<div class="grid cards" markdown>

-   **[၁ · Shell ကျွမ်းကျင်မှု (Shell Fluency)](01-shell.md)**

    ---

    Pipes၊ redirection၊ exit codes၊ variables နှင့် loops — fabric ရှိ စက်တိုင်းကို စစ်ဆေးပြီး ချို့ယွင်းနေသည်များကိုသာ သီးသန့် report ထုတ်ပေးသည့် script အထိ ရေးသားနိုင်မည်။

-   **[၂ · စက်ပစ္စည်း Output များကို Parse လုပ်ခြင်း](02-text-processing.md)**

    ---

    `grep`၊ `awk`၊ `sed` နှင့် `jq`။ `show` output များနှင့် JSON APIs များကို script က အရေးယူလုပ်ဆောင်နိုင်သော အချက်အလက်အဖြစ် ပြောင်းလဲခြင်း။

-   **[၃ · SSH ကို စနစ်တကျ သုံးစွဲနည်း](03-ssh.md)**

    ---

    Passwords အစား Keys သုံးခြင်း၊ SSH agent၊ `~/.ssh/config`၊ နှင့် jump hosts များ။ Automation tool တိုင်း မှီခိုနေရသော အခြေခံအုတ်မြစ်။

-   **[၄ · Processes, Services နှင့် Logs များ](04-services.md)**

    ---

    `systemd`၊ `journalctl`၊ နှင့် host-side network tools များ — `ss`၊ `curl`၊ `nc`၊ `mtr`။ ပြဿနာဖြစ်ပေါ်တတ်သော နေရာများနှင့် အကြောင်းရင်းကို ရှာဖွေနည်း။

-   **[၅ · ကွန်ရက် အင်ဂျင်နီယာများအတွက် Git](05-git.md)**

    ---

    Config များကို version control တွင် ထားရှိခြင်း၊ အဓိပ္ပာယ်ရှိသော diffs များ၊ branches နှင့် rollback များ။ Automation မစတင်မီ မဖြစ်မနေ လိုအပ်သောအဆင့်။

-   **[၆ · Linux Kernel Networking](06-kernel-networking.md)**

    ---

    `iproute2`၊ policy routing၊ network namespaces၊ `tcpdump` flag filters၊ kernel packet processing၊ နှင့် TCP socket troubleshooting။

-   **[၇ · Layer 1 Optics & Physical Infrastructure](07-physical-layer.md)**

    ---

    Transceivers (SFP+ မှ OSFP အထိ)၊ MMF/SMF fiber physics၊ Digital Optical Monitoring (DOM)၊ RS-FEC error correction၊ နှင့် port breakouts။

-   **[အင်တာဗျူး မေးခွန်းများ (Interview Questions)](interview-questions.md)**

    ---

    Track တစ်ခုလုံးကို လွှမ်းခြုံထားသော ကိုယ်တိုင်စစ်ဆေးနိုင်သည့် မေးခွန်းဘဏ်။

</div>

---

## လက်တွေ့ အသုံးဝင်မှုကို ပြသသော ဥပမာတစ်ခု

Fabric တစ်ခုလုံးရှိ BGP အခြေအနေကို စစ်ဆေးပေးသော command တစ်ကြောင်းတည်း — [Phase 1 lab](../01-bgp/lab-01-ebgp-ibgp.md) တွင် စမ်းသပ်ထားခြင်း:

```bash
for n in r1 r2 r3; do
  printf "%-4s " "$n"
  docker exec clab-bgp-lab-$n Cli -p 15 -c "show ip bgp summary" | grep -c Estab
done
```

```
r1   2
r2   1
r3   1
```

စက် ၃ လုံးကို စစ်ဆေးပြနိုင်ခြင်းသည် သာမန် trick တစ်ခုသာ ဖြစ်နိုင်သော်လည်း စက် ၃၀၀ ကို စစ်ဆေးခြင်းသည် သင်၏ နေ့စဉ်အလုပ် ဖြစ်လာပါမည် — သုံးရသည့် command ကတော့ ဤတစ်ကြောင်းတည်းပင် ဖြစ်ပါသည်။

---

## ဤသင်ရိုးက မည်သည့်နေရာသို့ ဦးတည်သနည်း

| နောက်တစ်ဆင့် | အဘယ်ကြောင့် ဤသင်ရိုး လိုအပ်သနည်း |
|---|---|
| **ဤနေရာရှိ Lab တိုင်း** | လက်ဖြင့် ရိုက်နှိပ်နေမည့်အစား ထပ်ခါတလဲလဲ အပိုင်းများကို script ဖြင့် ရေးသားနိုင်မည် |
| **Phase 5 · NetDevOps** | Ansible၊ Python နှင့် CI/CD တို့သည် ဤအရာများအားလုံးကို အခြေခံထားသည် |
| **ခေတ်မီ NOS တိုင်း** | cEOS၊ SONiC နှင့် cRPD တို့သည် အတွင်းပိုင်းတွင် Linux သာ ဖြစ်ကြသည် |

!!! note "Containerlab အလုပ်လုပ်ပုံကို ရှာဖွေနေပါသလား"
    Namespaces၊ veth pairs နှင့် cEOS container ဆိုင်ရာ အသေးစိတ်များကို **[Lab နည်းပညာ အလုပ်လုပ်ပုံ](../../getting-started/how-the-lab-works.md)** နှင့် **[Lab ပြဿနာ ဖြေရှင်းနည်းများ](../../getting-started/lab-troubleshooting.md)** သို့ ရွှေ့ပြောင်းထားပါသည်။
