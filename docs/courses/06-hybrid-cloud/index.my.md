# 🌐 Phase 6 · Enterprise WAN Edge & Dual-ISP Multihoming

> 🚀 **၁၀၀% မိမိစက်တွင်း စမ်းသပ်နိုင်သော Enterprise Architecture မာစတာတန်း**: Dual-ISP eBGP multihoming နှင့် BGP traffic engineering (AS-PATH prepending & communities) မှသည် sub-second BFD failover နှင့် local RPKI Route Origin Validation (ROV) အထိ စနစ်တကျ လေ့လာနိုင်ပါသည်။

---

## 🏛️ သင်တန်း ဗိသုကာနှင့် WAN Edge လမ်းပြမြေပုံ

Enterprise အခြေခံအဆောက်အအုံများကို အင်တာနက်နှင့် ချိတ်ဆက်ရာတွင် ISPs အများအပြားဖြင့် ခိုင်မာသော multihomed eBGP ချိတ်ဆက်မှုများ လိုအပ်ပါသည်။ Phase 6 သည် **၁၀၀% မိမိစက်တွင်း containerlab topologies** များပေါ်တွင် traffic များကို မည်သို့ဒီဇိုင်းဆွဲ၊ ချိတ်ဆက်၊ ထိန်းကျောင်းရမည်ကို လေ့ကျင့်ပေးပါသည်:

```
Phase 6 · Enterprise WAN Edge & Dual-ISP Multihoming
├── 🧪 Lab 01 · Active/Standby & Active/Active Dual-ISP eBGP Multihoming
├── 🧪 Lab 02 · Inbound & Outbound BGP Traffic Engineering (AS-PATH & Communities)
├── 🧪 Lab 03 · Sub-Second WAN Link Failover with BFD
└── 🧪 Lab 04 · Local RPKI Route Origin Validation (ROV) Simulation
```

---

## 🧠 Enterprise WAN Edge ဒီဇိုင်း အခြေခံမူများ

| ဗိသုကာ စိန်ခေါ်မှု | လုပ်ငန်းခွင် အင်ဂျင်နီယာ ဖြေရှင်းနည်း |
|---|---|
| ISP တစ်ခု ချို့ယွင်းသွားရုံဖြင့် ကွန်ရက် လုံးဝပြတ်တောက်သွားခြင်း | **ISPs နှစ်ခုနှင့် Multihomed eBGP ချိတ်ဆက်ခြင်း** (Primary `ASN 65100` / Backup `ASN 65200`) |
| ထိန်းချုပ်မရသော asymmetric အဝင်ယာဉ်ကြော | **AS-PATH Prepending** နှင့် **BGP Community tagging** အသုံးပြုခြင်း |
| စက္ကန့် ၁၈၀ ကြာသော BGP hold-timer ကြောင့် link ပြတ်တောက်မှုကို နောက်ကျမှ သိရှိခြင်း | **မီလီစက္ကန့်အတွင်း သိရှိနိုင်သော BFD (Bidirectional Forwarding Detection)** |
| BGP Route Hijacking အန္တရာယ် | **Local RPKI Route Origin Validation (ROV)** တပ်ဆင်ခြင်း |
