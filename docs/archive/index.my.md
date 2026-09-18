# မော်ကွန်းတိုက် (Archive) {: #archive }

ဖတ်ရှုလေ့လာရန် တန်ဖိုးရှိနေဆဲဖြစ်သော်လည်း လက်ရှိ active လမ်းကြောင်း မဟုတ်တော့သော အကြောင်းအရာများ။

ဤနေရာရှိ မည်သည့်အရာကိုမျှ ဖျက်ပစ်ခြင်း သို့မဟုတ် ဖုံးကွယ်ထားခြင်း မရှိပါ — အောက်ခံ platform ပြောင်းလဲသွားစေကာမူ သီအိုရီသဘောတရားများသည် အမြဲမှန်ကန်နေဆဲ ဖြစ်သောကြောင့် ဆက်လက်ထိန်းသိမ်းထားခြင်း ဖြစ်ပါသည်။

---

<div class="grid cards" markdown>

-   **Juniper ပေါ်ရှိ VXLAN-EVPN** &nbsp; <span class="nf-badge plan">ဖတ်ရှုရန်သာ</span>

    ---

    vJunos-switch ပေါ်တွင် ရေးသားထားသော သင်တန်းပြည့်စုံချက် — အပိုင်း ၁၀ ပိုင်းနှင့် lab လမ်းညွှန် ၅ ခု ပါဝင်ပြီး underlay, overlay, L2VNI နှင့် L3VNI, multi-tenancy, ESI multihoming, external connectivity နှင့် multi-site တို့ကို လွှမ်းခြုံထားပါသည်။

    [လမ်းကြောင်း ဖတ်ရှုရန် →](juniper-vxlan-evpn/index.my.md)

</div>

---

## ၎င်းကို မော်ကွန်းတိုက်သို့ အဘယ်ကြောင့် ရွှေ့ပြောင်းခဲ့သနည်း {: #why-it-was-archived }

vJunos-switch lab များသည် လက်တွေ့ run ရာတွင် တည်ငြိမ်မှု အားနည်းခဲ့သည်: Host တစ်ခုတည်းပေါ်တွင် virtual forwarding plane ၄ ခုကို တစ်ပြိုင်နက် boot တက်စေခြင်းသည် မကြာခဏ ကျရှုံးခဲ့ပြီး node များ degraded ဖြစ်ခြင်းနှင့် commit တွဲလောင်းဖြစ်ခြင်းများ ကြုံတွေ့ခဲ့ရသည်။ Host resource မလုံလောက်ခြင်း မဟုတ်ဘဲ node ၂ လုံးခန့်သည်သာ လက်တွေ့ကျသော အကန့်အသတ်ဖြစ်ခဲ့ရာ spine-leaf fabric တစ်ခုအတွက် မလုံလောက်ပါ။

ထို့ကြောင့် လက်တွေ့ lab လမ်းကြောင်းကို container ဖြစ်ပြီး မိနစ်ပိုင်းအတွင်း boot တက်ကာ laptop ပေါ်တွင် fabric အပြည့် run နိုင်သော **Arista cEOS** သို့ ပြောင်းလဲခဲ့ပါသည်။

!!! note "သီအိုရီသည် အမြဲမှန်ကန်နေဆဲ ဖြစ်သည်"
    EVPN route type များ၊ VXLAN encapsulation၊ route reflector design နှင့် multi-tenancy တို့သည် protocol အပြုအမူများဖြစ်ပြီး vendor တစ်ခုတည်းနှင့် မသက်ဆိုင်ပါ။ ထိုသင်ခန်းစာများသည် [လက်ရှိ EVPN အဆင့်](../courses/04-evpn/index.my.md) နှင့်အတူ ကောင်းစွာ တွဲဖက်ဖတ်ရှုနိုင်သည် — configuration syntax သာ ကွဲပြားပါသည်။

    သတိပြုရန်မှာ cloud VM မပါဘဲ အဆိုပါ lab များကို *run* ရန် မကြိုးစားသင့်ပါ။ လိုလားပါက [Cloud VM ပြင်ဆင်သတ်မှတ်ခြင်း](../getting-started/cloud-vm.my.md) ကို ကြည့်ရှုပါ။
