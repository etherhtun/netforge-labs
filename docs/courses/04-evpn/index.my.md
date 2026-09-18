# 🌐 Phase 4 · VXLAN-EVPN Datacenter Fabrics

> 🚀 **လုပ်ငန်းခွင် အင်ဂျင်နီယာ အထူးပြု မာစတာတန်း**: အခြေခံ overlay သဘောတရားများမှသည် လုပ်ငန်းခွင်သုံး CLOS fabrics၊ Symmetric IRB၊ ESI All-Active Multihoming၊ နှင့် Multi-Site DCI အထိ ကျွမ်းကျင်စွာ လေ့လာနိုင်ပါသည်။

---

## 🏛️ သင်တန်း ဗိသုကာနှင့် လက်တွေ့ လမ်းပြမြေပုံ

Phase 4 သည် **အဆင့်ဆင့် တက်လှမ်းရသော လက်တွေ့ lab modules ၅ ခု** ဖြင့် လမ်းညွှန်ပေးပါမည်။ Lab တစ်ခုချင်းစီသည် ယခင် lab ပေါ်တွင် အခြေခံထားပြီး Layer 2 VXLAN extension သက်သက်မှသည် data centers အချင်းချင်းကြား ချိတ်ဆက်မှု (DCI) အထိ အဆင့်ဆင့် တည်ဆောက်သွားမည် ဖြစ်ပါသည်:

```
Phase 4 · VXLAN-EVPN Datacenter Fabrics
├── 🧪 Lab 01 · Pure L2VNI (Bridging, BUM Head-End Replication & EVPN RT2/3)
├── 🧪 Lab 02 · Integrated Routing & Bridging (Symmetric IRB & Anycast Gateway)
├── 🧪 Lab 03 · ESI All-Active Multihoming (DF Election & Split-Horizon)
├── 🧪 Lab 04 · EVPN-VPWS & EVPN-ELAN (Point-to-Point VPWS & Multipoint ELAN)
└── 🧪 Lab 05 · VXLAN-EVPN DCI & Multi-Site (Border Gateway VTEPs)
```

---

## 📚 သင် ကျွမ်းကျင်ပိုင်နိုင်မည့် အကြောင်းအရာများ

### ၁။ အခြေခံ အုတ်မြစ်များ (Foundations)
- **VXLAN-EVPN ကို အဘယ်ကြောင့် သုံးရသနည်း**: ရှေးရိုး Spanning Tree (STP) နှင့် vendor အလိုက် သီးသန့် MLAG/vPC များကို ဖယ်ရှားပြီး open-standard 5-stage CLOS Spine-Leaf fabrics များဖြင့် အစားထိုးခြင်း။
- **50-Byte Header Encapsulation**: Outer Ethernet + Outer IP + UDP 4789 + 24-bit VNI + Inner Payload ဖွဲ့စည်းပုံ။
- **MTU 9214 Jumbo Frame စံနှုန်း**: ကွန်ရက်လမ်းကြောင်းတစ်လျှောက် fragmentation မဖြစ်ပေါ်စေရန် ကာကွယ်ခြင်း။

### ၂။ Control Plane အသေးစိတ် လုပ်ဆောင်ချက်များ (BGP EVPN AFI 25 / SAFI 70)
- **Route Type 1 (Auto-Discovery)**: ESI multihoming၊ mass withdraw၊ နှင့် Split-Horizon loop filtering။
- **Route Type 2 (MAC/IP Advertisement)**: Control-plane MAC learning နှင့် L2/L3 host prefix ကြေညာမှုများ။
- **Route Type 3 (Inclusive Multicast / IMET)**: BUM traffic များကို Head-End Replication (HER) ဖြင့် ပို့ဆောင်ရန် VTEP များကို dynamic ရှာဖွေခြင်း။
- **Route Type 4 (Ethernet Segment)**: ESI segments များတွင် Designated Forwarder (DF) ကို အလိုအလျောက် ရွေးချယ်ခြင်း။
- **Route Type 5 (IP Prefix Route)**: Subnet အချင်းချင်းကြား VRF prefix routing ပြုလုပ်ခြင်း။

### ၃။ လုပ်ငန်းခွင်သုံး အကောင်းဆုံး အလေ့အကျင့်များ (Best Practices)
- **Anycast Virtual Gateway Standard**: Leafs အားလုံးတွင် တူညီသော Virtual IP (`10.10.10.1/24`) နှင့် Virtual MAC (`00:1c:73:00:00:01`) ချမှတ်ခြင်း။
- **Symmetric IRB Architecture**: Multi-tenancy သန့်ရှင်းစေရန် L3 VNI (`50001`) မှတစ်ဆင့် ingress နှင့် egress Leafs နှစ်ခုစလုံးတွင် dual-routing ပြုလုပ်ခြင်း။
- **ESI All-Active Multihoming**: MLAG peer-links မလိုဘဲ Active-Active server ချိတ်ဆက်မှုကို ရယူခြင်း။
