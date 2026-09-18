# အင်တာဗျူး မေးခွန်းများ — အဆင့် ၃ · MPLS & L3VPN {: #interview-questions-phase-3-mpls-l3vpn }

ဤကိုယ်တိုင်စစ်ဆေးနိုင်သော မေးခွန်းများသည် **Google Network Infrastructure Engineer (NIE)**၊ **Service Provider Backbone Engineer**၊ နှင့် **WAN Systems Engineer** နည်းပညာဆိုင်ရာ အင်တာဗျူး မေးခွန်းများကို အဓိက ဦးတည်ထားပါသည်။

---

## MPLS Underlay နှင့် LDP လုပ်ဆောင်ချက်များ {: #mpls-underlay-ldp-mechanics }

??? question "MPLS label switching သည် သမားရိုးကျ IP routing နှင့် မည်သို့ ကွာခြားသနည်း။"
    သမားရိုးကျ IP routing သည် router hop တိုင်းတွင် 32-bit destination IPv4 address ပေါ်၌ **longest-prefix match (LPM)** ရှာဖွေမှုကို လုပ်ဆောင်သည်။ **MPLS (Multiprotocol Label Switching)** သည် MPLS shim header ထဲရှိ တိုတောင်းသော အလျားသတ်မှတ်ထားသည့် 20-bit label ကို စစ်ဆေးပြီး label ကို swap သို့မဟုတ် pop လုပ်ရန် $O(1)$ exact-match hardware table lookup ကို လုပ်ဆောင်ခြင်းဖြင့် core P router များတွင် routing table အပြည့်အစုံ ရှာဖွေရခြင်းကို ရှောင်ရှားနိုင်စေသည်။

??? question "Penultimate Hop Popping (PHP) ဆိုသည်မှာ အဘယ်နည်း၊ ၎င်းကို အဘယ်ကြောင့် အသုံးပြုသနည်း။"
    **Penultimate Hop Popping (PHP)** သည် RFC 3032 တွင် သတ်မှတ်ထားသော MPLS စွမ်းဆောင်ရည်မြှင့်တင်မှု ဖြစ်သည်။ Egress PE သည် ၎င်း၏ အထက်ရှိ P router သို့ **Implicit Null Label (Label 3)** ကို ကြေညာပေးသည်။ အထက်ရှိ P router သည် egress PE သို့ packet မပေးပို့မီ transport label ကို ကြိုတင်ဖြုတ်ပယ် (pop) ပေးသည်။ ၎င်းသည် egress PE အား hardware label lookup နှစ်ကြိမ် (transport label + service label) ပြုလုပ်ရခြင်းမှ သက်သာစေပါသည်။

---

## L3VPN နှင့် MP-BGP (RFC 4364) {: #l3vpn-mp-bgp-rfc-4364 }

??? question "Route Distinguisher (RD) နှင့် Route Target (RT) အကြား ခြားနားချက်မှာ အဘယ်နည်း။"
    - **Route Distinguisher (RD — 64 bits)**: 32-bit IPv4 customer address ရှေ့တွင် RD ကို ထပ်ပေါင်း၍ 96-bit VPNv4 prefix (`RD + IPv4 = VPNv4`) ဖွဲ့စည်းပေးခြင်းဖြင့် ထပ်တူကျနေသော IP လိပ်စာများကို တစ်ကမ္ဘာလုံးအတိုင်းအတာဖြင့် တစ်မူထူးခြားစေသည်။
    - **Route Target (RT — Extended Community)**: **VRF routing မူဝါဒ** ကို သတ်မှတ်သည်။ Provider ကွန်ရက်တစ်လျှောက် မည်သည့် VRF များက သီးခြား VPNv4 route များကို import နှင့် export ပြုလုပ်ရမည်ကို ဆုံးဖြတ်ပေးသည်။

??? question "Core ထံမှ packet တစ်ခု လက်ခံရရှိသောအခါ PE router သည် မတူညီသော customer VRF များမှ traffic များကို မည်သို့ ခွဲခြားသိရှိနိုင်သနည်း။"
    Packet သည် ၎င်း၏ MPLS label stack ထဲတွင် **Inner VPN Service Label** ကို သယ်ဆောင်လာသည်။ MP-BGP သည် VPNv4 route တစ်ခုကို ကြေညာသည့်အခါ အဆိုပါ prefix/VRF အတွက် သီးသန့် service label တစ်ခုကို သတ်မှတ်ပေးသည်။ Egress PE သည် destination VRF နှင့် egress interface ကို ခွဲခြားသိရှိနိုင်ရန် ၎င်း၏ LFIB (Label Forwarding Information Base) ထဲတွင် ထို inner label ကို ရှာဖွေစစ်ဆေးသည်။

---

## Inter-AS L3VPN Options A, B, နှင့် C {: #inter-as-l3vpn-options-a-b-and-c }

??? question "ASBR စကေးချဲ့နိုင်စွမ်း (scalability) ရှုထောင့်မှ Inter-AS L3VPN Options A, B, နှင့် C တို့ကို နှိုင်းယှဉ်ပြပါ။"
    - **Option A (Back-to-Back VRFs)**: စကေးချဲ့နိုင်စွမ်း နည်းပါးသည်။ ASBR များသည် customer တိုင်းအတွက် sub-interface များ၊ VRF များနှင့် သီးခြား eBGP session များကို ချိန်ညှိရသည်။ Memory/CPU ဝန်ထုပ်ဝန်ပိုး မြင့်မားသည်။
    - **Option B (Inter-AS MP-eBGP VPNv4)**: အသင့်အတင့်/မြင့်မားသော စကေးချဲ့နိုင်စွမ်း ရှိသည်။ ASBR များသည် MP-eBGP ပေါ်တွင် VPNv4 route များကို တိုက်ရိုက်ဖလှယ်ပြီး Next-Hops/labels များကို ပြန်လည်ပြင်ဆင်ပေးသည်။ ASBR များပေါ်တွင် customer VRF မလိုပါ။
    - **Option C (BGP-LU RFC 3107 + Multi-hop MP-eBGP)**: **Hyperscale အဆင့်**။ ASBR များသည် customer VPN route များကို သယ်ဆောင်ရန် မလိုဘဲ BGP Labeled Unicast (BGP-LU) မှတစ်ဆင့် PE loopback reachability ကိုသာ ဖလှယ်ပေးသည်။ PE များသည် multi-hop MP-eBGP ဖြင့် တိုက်ရိုက် peer ပြုလုပ်သည်။

??? question "Hyperscalers (Google, AWS, Meta) များသည် Option A သို့မဟုတ် B ထက် Inter-AS Option C ကို အဘယ်ကြောင့် ပိုမိုနှစ်သက်ကြသနည်း။"
    Option C သည် backbone ASBR core အား customer VPN control plane state မှ လုံးဝ သီးခြားခွဲထုတ်ပေးထားသည်။ ASBR များသည် သန်းပေါင်းများစွာသော customer VPN route များအစား loopback prefix ($\sim 10,000$ PEs ခန့်သာ) ကို သိမ်းဆည်းရန် လိုအပ်သည်။ ၎င်းသည် ASBR router memory သို့မဟုတ် TCAM state ကုန်ဆုံးသွားခြင်းမရှိဘဲ ကွန်ရက်စွမ်းရည်ကို အကန့်အသတ်မရှိ ချဲ့ထွင်နိုင်စေပါသည်။
