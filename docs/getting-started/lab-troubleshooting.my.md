# Lab ပြဿနာ ဖြေရှင်းနည်းများ — cEOS အဘယ်ကြောင့် ဤသို့ ပြုမူသနည်း

ဤသင်ရိုးညွှန်းတမ်းကို တည်ဆောက်စဉ် အချိန်ကုန်စေခဲ့သော bugs ၃ ခု ရှိခဲ့ပါသည်။ မည်သည့်အရာမျှ networking ပြဿနာ မဟုတ်ပါ။ သို့သော် container ဆိုသည်မှာ အဘယ်နည်းကို သဘောပေါက်ပါက အဆိုပါ bugs ၃ ခုစလုံးသည် ချက်ချင်း ရှင်းလင်းသွားပါမည်။

---

## Container ဆိုသည်မှာ သေးငယ်သော VM မဟုတ်ပါ

Virtual machine တစ်ခုသည် hardware ကို emulate ပြုလုပ်ပြီး ကိုယ်ပိုင် kernel ကို run ပါသည်။ Container သည် ထိုအရာ ၂ ခုစလုံးကို မလုပ်ပါ။ ၎င်းသည် အောက်ပါ စွမ်းဆောင်ချက် ၂ ခုကို သုံးပြီး kernel က ၎င်း၏ ပတ်ဝန်းကျင်ကို လှည့်စားထားသော **သာမန် Linux process တစ်ခုမျှသာ** ဖြစ်ပါသည်:

- **Namespaces** — Process တစ်ခုက မည်သည့်အရာကို *မြင်တွေ့နိုင်သည်* ကို ထိန်းချုပ်သည်: ၎င်း၏ ကိုယ်ပိုင် PIDs၊ mounts၊ hostname၊ နှင့် ၎င်း၏ ကိုယ်ပိုင် network stack။
- **cgroups** — ၎င်းက မည်သည့်အရင်းအမြစ်ကို *သုံးစွဲနိုင်သည်* ကို ထိန်းချုပ်သည်: CPU၊ memory၊ I/O။

ဒါပါပဲ။ [Lab နည်းပညာ အလုပ်လုပ်ပုံ](how-the-lab-works.md) တွင် `docker inspect -f '{{.State.Pid}}'` က ပြန်ပေးခဲ့သော `30498` ဆိုသည်မှာ သင်၏ host ပေါ်ရှိ သာမန် process table ထဲက PID တစ်ခုသာ ဖြစ်ပြီး `ps` တွင် မြင်နိုင်ကာ `kill` ဖြင့် ဖျက်နိုင်ပါသည်။ မည်သည့် hardware မှ virtualize လုပ်မထားပါ။

ထို့ကြောင့် cEOS fabric တစ်ခုသည် vJunos ကဲ့သို့ မိနစ်နှင့်ချီ မကြာဘဲ စက္ကန့်ပိုင်းအတွင်း boot တက်နိုင်ခြင်း ဖြစ်ပါသည်: စတင်ရန် kernel မလိုပါ၊ emulate လုပ်ရန် hardware မရှိပါ။ တစ်ချိန်တည်းမှာပင် ၎င်းသည် သင်၏ host kernel ကို မျှဝေသုံးစွဲရသောကြောင့် အချို့သော kernel-level အပြုအမူများကို အပြည့်အဝ emulate မလုပ်နိုင်ပါ။

!!! note "အလေးထားရမည့် အကျိုးဆက်"
    Container တစ်ခုသည် သီးသန့် network namespace ပါဝင်သော process တစ်ခုသာ ဖြစ်သောကြောင့် **အတွင်းရှိ NOS သည် Linux စည်းမျဉ်းများ၏ လက်အောက်တွင် ရှိနေပါသည်** — process lifecycle၊ stdin/stdout၊ interface naming conventions များ။ အကယ်၍ ပုံမှန်မဟုတ်သော အပြုအမူများ ဖြစ်ပေါ်ပါက routing stack ကြောင့် မဟုတ်ဘဲ Linux semantics များကြောင့် ဖြစ်နိုင်ခြေ အလွန်များပါသည်။

    အောက်ပါ bugs ၃ ခုစလုံးသည် အတိအကျ ထိုသို့ ဖြစ်ပေါ်ခဲ့ခြင်း ဖြစ်ပါသည်။

---

## Bug 1 — Interface အမည် သတ်မှတ်ချက် စည်းမျဉ်း

**ပြဿနာလက္ခဏာ:** Nodes များသည် `Connected 0 interfaces out of 2` တွင် ရပ်တန့်နေပြီး EOS မည်သည့်အခါမျှ boot မတက်တော့ပါ။ Topology ဖိုင်ကို ကြည့်ပါက အမှန်အတိုင်း ဖြစ်နေသည်။

**ဖြစ်ရသည့်အကြောင်းရင်း:** Topology ဖိုင်တွင် endpoint အမည်အဖြစ် `Ethernet1` ကို အသုံးပြုထားခြင်းကြောင့် ဖြစ်သည်:

```yaml
links:
  - endpoints: ["p1:Ethernet1", "pe1:Ethernet1"]   # ✗ ရပ်တန့်သွားမည်
```

cEOS ၏ entrypoint script သည် EOS မစတင်မီ containerlab ၏ wiring အပြီးသတ်မှုကို စောင့်ဆိုင်းပြီး၊ ၎င်း၏ namespace အတွင်း **`eth*` နှင့် ကိုက်ညီသော interfaces များကို ရေတွက်ခြင်းဖြင့်** အပြီးသတ်မှုကို စစ်ဆေးပါသည်။ `Ethernet1` ဟု အတိအကျ အမည်ပေးထားသော veth သည် အဆိုပါ `eth*` pattern နှင့် မကိုက်ညီသောကြောင့် အရေအတွက်မှာ သုည ဖြစ်နေပြီး entrypoint သည် ထာဝစဉ် စောင့်ဆိုင်းနေတော့သည်။

**ဖြေရှင်းနည်း** — Topology ဖိုင်တွင် စာလုံးအသေး `ethN` ကို သုံးပါ:

```yaml
links:
  - endpoints: ["p1:eth1", "pe1:eth1"]   # ✓ မှန်ကန်သည်
```

EOS အတွင်း၌ ၎င်းတို့သည် `Ethernet1` နှင့် `Ethernet2` အဖြစ် ပုံမှန်အတိုင်း ဆက်လက် ပြသပါမည်။ Linux အမည်နှင့် NOS အမည်တို့သည် layer မတူညီကြပါ; Linux layer ကသာ pattern နှင့် ကိုက်ညီရန် လိုအပ်ပါသည်။

---

## Bug 2 — တိတ်ဆိတ်စွာ Config မဝင်ခြင်း (The Silent Failure)

**ပြဿနာလက္ခဏာ:** Heredoc config block တစ်ခုသည် ချက်ချင်းပြီးဆုံးသွားပြီး မည်သည့်အရာမျှ မပြဘဲ exit code `0` ဖြင့် ပြီးသွားသည်။ သို့သော် မည်သည့် config မှ မဝင်ပါ၊ မည်သည့် error မှ မပြပါ။

```bash
docker exec clab-ceos-mpls-scratch-p1 Cli -p 15 <<'EOF'    # ✗ တိတ်တဆိတ် မည်သည့်အရာမှ မလုပ်ပါ
configure
interface Ethernet1
 ip address 10.1.1.1/24
EOF
```

**ဖြစ်ရသည့်အကြောင်းရင်း:** `docker exec` သည် မသတ်မှတ်မချင်း stdin ကို ချိတ်ဆက်မပေးပါ။ Heredoc သည် မည်သူမျှ မဖတ်ရှုသော pipe တစ်ခုထဲသို့ ရောက်သွားသည်။ `Cli` စတင်လာပြီး stdin ဗလာဖြစ်နေသဖြင့် အလိုအလျောက် ပိတ်သွားသည် — output မပါဘဲ exit code `0` ထွက်လာခြင်းက အောင်မြင်သည့်ပုံစံနှင့် အတူတူပင် ဖြစ်နေသည်။

**ဖြေရှင်းနည်း** — Interactive stdin အတွက် `-i` ကို အသုံးပြုပါ:

```bash
docker exec -i clab-ceos-mpls-scratch-p1 Cli -p 15 <<'EOF'   # ✓ မှန်ကန်သည်
configure
interface Ethernet1
 ip address 10.1.1.1/24
EOF
```

!!! warning "ဤအမှားသည် တိတ်ဆိတ်လွန်းသဖြင့် အလွန် အန္တရာယ်ကြီးပါသည်"
    Crash မဖြစ်ဘဲ exit `0` ထွက်ကာ ဘာမျှမပြသော failure သည် အဆိုးဆုံး ဖြစ်သည်။ Scripts များသည် ဆက်လက် run သွားမည်ဖြစ်ပြီး နောက်အဆင့်များသည် config မဝင်ထားသော စက်ပေါ်တွင် "အောင်မြင်" သွားကာ နောက်ဆုံးတွင် လုံးဝမသက်ဆိုင်သော အခြားနေရာတစ်ခုတွင် ပြဿနာ ထူးဆန်းစွာ ပေါ်လာတတ်သည်။

    **စည်းမျဉ်း: `docker exec` ထဲသို့ heredoc သွင်းတိုင်း အမြဲတမ်း `-i` လိုအပ်ပါသည်။**

---

## Bug 3 — Lab Node တစ်ခုကို `docker restart` လုံးဝ မလုပ်ပါနှင့်

**ပြဿနာလက္ခဏာ:** Container တစ်ခုကို restart လုပ်ပြီးနောက် ၎င်း၏ data-plane interfaces များ အားလုံး ပျောက်ကွယ်သွားသည်။ `show interfaces` တွင် management interface သာ ကျန်ရှိတော့ပြီး မည်သည့် error မှ မပြပါ။

**ဖြစ်ရသည့်အကြောင်းရင်း:** Containerlab သည် veth pairs များကို တည်ဆောက်ပြီး container တစ်ခုချင်းစီ၏ namespace ထဲသို့ ထည့်သွင်းပေးထားခြင်း ဖြစ်သည်။ အဆိုပါ namespace သည် container ၏ main process ပေါ်တွင် တည်ရှိသည်။ Container ကို restart လုပ်လိုက်ခြင်းသည် **namespace ကို ဖျက်ဆီးပစ်လိုက်ပြီး** အတွင်းရှိ veths များပါ တစ်ပါတည်း ပျက်ပြယ်သွားသည်။

Container ပြန်တက်လာချိန်တွင် လတ်ဆတ်သော ဗလာ namespace ဖြင့်သာ ပြန်တက်လာသည်။ Containerlab က လည်ပတ်မနေသောကြောင့် မည်သူမျှ ကြိုးပြန်ချိတ်မပေးတော့ပါ။

**ဖြေရှင်းနည်း** — Container ကို မဟုတ်ဘဲ topology ကိုသာ ပြန်လည် တည်ဆောက်ပါ:

```bash
sudo containerlab destroy -t topology.clab.yml
sudo containerlab deploy -t topology.clab.yml
```

!!! tip "EOS အတွင်းမှ Reload ပြုလုပ်ခြင်းလည်း အလုပ်မဖြစ်ပါ"
    EOS prompt တွင် `reload` ရိုက်နှိပ်ခြင်းသည် NOS process ကို restart ပြုလုပ်ခြင်းဖြစ်ပြီး container အတွင်းတွင် PID 1 ကို restart ပြုလုပ်ခြင်းဖြစ်၍ container တစ်ခုလုံး ရပ်တန့်သွားစေပါသည်။ ထွက်ပေါ်လာသော ရလဒ်မှာ အတူတူပင် ဖြစ်သည်။

---

## The Boot Race — အချိန်ကိုက် ပြိုင်ဆိုင်မှု ပြဿနာ

**ပြဿနာလက္ခဏာ:** Node တစ်ခု တက်လာချိန်တွင် ရံဖန်ရံခါ `show interfaces Ethernet1 status` ၌ type `Unknown` ဟု ပြနေခြင်း။ Destroy လုပ်ပြီး ပြန် deploy ပါက ပုံမှန်အတိုင်း ကောင်းသွားသည်။

**ဖြစ်ရသည့်အကြောင်းရင်း:** အချိန်ကိုက်ပြဿနာ (Timing) ဖြစ်သည်။ Apple Silicon ပေါ်ရှိ Rosetta emulation အောက်တွင် x86 containers များသည် native ထက် နှေးကွေးစွာ အလုပ်လုပ်သည်။ စက်အများအပြား တစ်ပြိုင်နက် boot တက်ချိန်တွင် containerlab က veths အားလုံးကို နေရာချမပြီးမီ node ၏ EOS က interfaces များကို scan စတင်လုပ်လိုက်မိခြင်း ဖြစ်သည်။

**ဖြေရှင်းနည်း** — Startup ကို တန်းစီ၍ စတင်စေခြင်း:

```bash
sudo containerlab deploy -t topology.clab.yml --max-workers 1
```

ပြီးနောက် configure မလုပ်မီ health-check အမြဲ စစ်ဆေးပါ: Data-plane interface တိုင်းသည် စစ်မှန်သော type ကို ပြသနေရမည်ဖြစ်ပြီး `Unknown` လုံးဝ မဖြစ်ရပါ။

---

## ပြဿနာ ပုံစံများ အကျဉ်းချုပ် (The Pattern)

| ချို့ယွင်းချက် (Bug) | အပေါ်ယံ မြင်တွေ့ရပုံ | အမှန်တကယ် ဖြစ်ပျက်နေပုံ |
|---|---|---|
| `Connected 0 interfaces` | Topology ပျက်စီးနေပုံ | Interface **အမည် format မကိုက်ညီခြင်း** |
| Config တိတ်တဆိတ် မဝင်ခြင်း | CLI error ဖြစ်ပုံ | **stdin** ချိတ်ဆက်မထားမိခြင်း |
| Restart ပြီးနောက် interfaces ပျောက်သွားခြင်း | Node ပျက်စီးသွားပုံ | **Namespace** ဖျက်ဆီးခံလိုက်ရခြင်း |
| Interface type `Unknown` ပြနေခြင်း | Image မကောင်းပုံ | Processes များကြား **ပြိုင်ဆိုင်မှု (Race condition)** |

၎င်းတို့အားလုံးသည် networking tool တစ်ခုမှတစ်ဆင့် ပေါ်ထွက်လာသော Linux အပြုအမူများသာ ဖြစ်ကြပါသည်။ မည်သည့်အရာကိုမျှ `show` commands ဖြင့် ရှာဖွေမရနိုင်ဘဲ အောက်ခံ layer ကို မြင်တတ်ပါက ရိုးရှင်းသော ကိစ္စများသာ ဖြစ်ပါသည်။
