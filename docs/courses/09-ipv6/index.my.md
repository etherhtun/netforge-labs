# 🌐 Phase 9 · IPv6 Transition & Dual-Stack Infrastructure

> 🚀 **၁၀၀% မိမိစက်တွင်း စမ်းသပ်နိုင်သော Enterprise & SP IPv6 မာစတာတန်း**: IPv6 Neighbor Discovery (ND) နှင့် SLAAC မှသည် BGP Unnumbered over IPv6 Link-Local (RFC 5549 / RFC 8950)၊ 6PE/6VPE over MPLS၊ နှင့် Stateful NAT64/DNS64 ဘာသာပြန်ခြင်း စနစ်များအထိ စနစ်တကျ လေ့လာနိုင်ပါသည်။

---

## 🏛️ သင်တန်း ဗိသုကာနှင့် IPv6 လမ်းပြမြေပုံ

IPv6-only data center underlays နှင့် dual-stack enterprise edges များသို့ ကူးပြောင်းခြင်းသည် IPv4 address ပြတ်လပ်မှု၊ NAT ဝန်ပိမှု၊ နှင့် စီမံခန့်ခွဲမှုဆိုင်ရာ overhead များကို ဖယ်ရှားပေးပါသည်။ Phase 9 သည် **၁၀၀% မိမိစက်တွင်း စမ်းသပ်နိုင်သော IPv6 network architectures** များကို မည်သို့ တည်ဆောက်ရမည်ကို လေ့ကျင့်ပေးပါသည်:

```
Phase 9 · IPv6 Transition & Dual-Stack Infrastructure
├── 🧪 Lab 01 · IPv6 Neighbor Discovery (ND) နှင့် SLAAC / DHCPv6
├── 🧪 Lab 02 · BGP Unnumbered (BGP over IPv6 Link-Local RFC 5549)
├── 🧪 Lab 03 · 6PE & 6VPE (MPLS Backbones ပေါ်မှ IPv6 Provider Edge)
└── 🧪 Lab 04 · Stateful NAT64 & DNS64 Translation လုပ်ဆောင်ချက်များ
```

---

## 🧠 IPv6 ဗိသုကာနှင့် ကူးပြောင်းမှုဆိုင်ရာ အခြေခံမူများ

| ဗိသုကာ စိန်ခေါ်မှု | လုပ်ငန်းခွင် အင်ဂျင်နီယာ ဖြေရှင်းနည်း |
|---|---|
| IPv4 Address ပြတ်လပ်မှုနှင့် NAT ဝန်ပိမှု | **IPv6 Global Unicast Addressing (`2001:db8::/32`)** |
| Point-to-Point Links များတွင် Subnetting ဝန်ပိမှု | **BGP Unnumbered over IPv6 Link-Local (`fe80::/10`) (RFC 5549)** |
| ရှေးဟောင်း IPv4 Core ကိုဖြတ်၍ IPv6 သယ်ယူပို့ဆောင်ခြင်း | **6PE (MPLS ပေါ်မှ IPv6 Provider Edge)** |
| IPv6-only Host မှ ရှေးဟောင်း IPv4 ဝန်ဆောင်မှုများကို ရယူသုံးစွဲခြင်း | **Stateful NAT64 & DNS64 Translation (`64:ff9b::/96`)** |
