# သင်တန်း ၁: Juniper ပေါ်ရှိ VXLAN-EVPN {: #course-1-vxlan-evpn-on-juniper }

Juniper ပေါ်တွင် VXLAN-EVPN ကို စနစ်တကျ အပြည့်အစုံ လေ့လာနိုင်မည့် လမ်းကြောင်းဖြစ်ပြီး **သင်ခန်းစာတစ်ခုချင်းစီ (session by session)** ဖွဲ့စည်းထားပါသည်။ (Cisco ဆိုင်ရာ သင်တန်းကိုလည်း ရေးဆွဲရန် စီစဉ်ထားသည်)။ သင်ခန်းစာတစ်ခုစီတိုင်းသည် တူညီသော သင်ကြားမှုပုံစံကို လိုက်နာပါသည်:

1. **စိတ်ကူးပုံစံ (Mental model)** — သဘောတရားကို အခြေပြုနားလည်စေမည့် နှိုင်းယှဉ်ချက်။
2. **အဘယ်ကြောင့်သုံးသည် (Why before how)** — Config မလုပ်မီ ဤ session က မည်သည့်ပြဿနာကို ဖြေရှင်းပေးသည်ကို ဦးစွာသိရှိခြင်း။
3. **လုပ်ဆောင်မှု နည်းစနစ် (The mechanism)** — နည်းပညာအနက်: ကြိုးပေါ်တွင်နှင့် control plane ထဲတွင် အမှန်တကယ် မည်သို့ဖြစ်ပျက်နေပုံ။
4. **လက်တွေ့တည်ဆောက်ခြင်း (Build it)** — Config များကို တစ်ကြောင်းချင်းစီ ရှင်းပြထားသော လက်တွေ့ lab။
5. **စစ်ဆေးအတည်ပြုခြင်း (Verify)** — `show` command များနှင့် ၎င်းတို့၏ output များကို *မည်သို့ဖတ်ရှုရမည်* ဆိုသည့်အချက်။
6. **စနစ်ပျက်ယွင်းအောင်ပြုလုပ်၍ လေ့လာခြင်း (Break & observe)** — ကျရှုံးမှုပုံစံကို တွေ့မြင်နိုင်ရန် တမင်ဖျက်ဆီးလေ့လာခြင်း။
7. **သင်ခန်းစာများနှင့် အင်တာဗျူး (Lessons & interview)** — သတိပြုရန်အချက်များနှင့် အင်တာဗျူးတွင် မေးလေ့ရှိသော မေးခွန်းများ။

> တည်ဆောက်မှုအစီအစဉ်သည် လက်တွေ့ဘဝအတိုင်း ဖြစ်သည်: **underlay → overlay → services → scale**။ အောက်ခံအလွှာကို အတည်မပြုရသေးဘဲ မည်သည့်အထက်အလွှာကိုမျှ စတင် configure မလုပ်ရပါ။

## သင်ခန်းစာများ (Sessions) {: #sessions }

| # | Session | သင်ကျွမ်းကျင်လာမည့် အကြောင်းအရာ | အခြေအနေ |
|---|---------|---------------|--------|
| ၀ | [Lab Platform](../../getting-started/cloud-vm.my.md) | GCP + containerlab + vJunos | ✅ |
| ၁ | [Underlay (OSPF)](01-underlay.md) | Loopback reachability, ECMP, SPF | ✅ |
| ၂ | [Overlay (iBGP-EVPN + Route Reflectors)](02-overlay-rr.md) | BGP-EVPN, RD/RT, RR | ✅ |
| ၃ | [L2VNI — VLAN ဆွဲဆန့်ခြင်း](03-l2vni.md) | Bridging, Type-2/Type-3, Flood lists | ✅ |
| ၄ | [Anycast Gateway & L3VNI](04-l3vni-anycast.md) | Inter-subnet routing, Type-5, Symmetric IRB | ✅ (lab မူကြမ်း) |
| ၅ | [Multi-tenancy](05-multitenancy.md) | VRFs, Route leaking, RT policy | ✅ (lab မူကြမ်း) |
| ၆ | [ESI Multihoming](06-esi-multihoming.md) | Dual-homed hosts, Type-1/Type-4, DF election | ✅ (lab မူကြမ်း) |
| ၇ | [eBGP ဒီဇိုင်းများ](07-ebgp.md) | eBGP underlay, eBGP-EVPN overlay | ✅ သင်ကြားမှု |
| ၈ | [ပြင်ပ ချိတ်ဆက်မှု (L3 out)](08-l3out.md) | WAN သို့ routing ပြုလုပ်ခြင်း, Default origination | ✅ သင်ကြားမှု |
| ၉ | [Multi-site / DCI](09-multisite.md) | Fabric များကို အချင်းချင်း ချိတ်ဆက်ခြင်း | ✅ သင်ကြားမှု |

### ထုတ်လုပ်မှုနှင့် အဆင့်မြင့် လမ်းကြောင်း {: #production-advanced-track }

| # | Session | သင်ကျွမ်းကျင်လာမည့် အကြောင်းအရာ | အခြေအနေ |
|---|---------|---------------|--------|
| ၁၀ | [Production Hardening](10-production-hardening.md) | MTU, BFD, CoPP, Auth, Guard-rails, Prod checklist | ✅ |
| ၁၁ | MAC Mobility & Duplicate Detection | VM ရွှေ့ပြောင်းခြင်း, Sequence numbers, Loop protection | 🏗️ နောက်ထပ် |
| ၁၂ | CRB vs ERB Gateway Design | L3 gateway တည်ရှိရာနေရာ | 📋 |
| ၁၃ | DHCP Relay in EVPN-VXLAN | VNI/Tenant များတစ်လျှောက် IP ချထားပေးခြင်း | 📋 |
| ၁၄ | ပြဿနာဖြေရှင်းမှု နည်းစနစ် | အလွှာလိုက် စနစ်တကျ စစ်ဆေးသော debug လမ်းကြောင်း | 📋 |

## အခြား အပိုင်းများနှင့် ဆက်စပ်ပုံ {: #how-this-relates-to-the-other-sections }

- **[သီအိုရီ လေ့လာမှု လမ်းကြောင်း](../../courses/04-evpn/concepts/index.my.md)** — ပိုမိုတိုတောင်းသော အခြေခံသဘောတရားများ။ Session အပြည့်အစုံ မဖတ်မီ ၅ မိနစ်စာ အကျဉ်းချုပ်ကို လိုချင်ပါက ဖတ်ရှုပါ။
- **[Labs](labs/index.md)** — တိုက်ရိုက် run နိုင်သော fabric များ (`clab-*`)။
- **Sessions (ဤနေရာ)** — အသေးစိတ် လမ်းညွှန်ထားသော သင်တန်း။ အရာအားလုံးကို စနစ်တကျ လေ့လာလိုပါက **ဤနေရာမှ စတင်ပါ**။
