# ၄ · Policy နှင့် Filtering စနစ်

ဤသည်မှာ သာမန် routing သဘောတရား မဟုတ်သော BGP ၏ အခြားတစ်ဝက်ဖြစ်သည်။ မည်သည့်အရာကို လက်ခံမည်၊ မည်သည့်အရာကို အပြင်သို့ ကြေညာမည်၊ လမ်းကြောင်းတစ်ခုစီကို မည်မျှ ဆွဲဆောင်မှုရှိစေမည် စသည်တို့ကို Policy က ဆုံးဖြတ်ပေးသည်။

---

## Prefix Lists — မည်သည့် Prefixes များကို ရွေးချယ်မည်နည်း

Prefix နှင့် ၎င်း၏ subnet length အပေါ် မူတည်၍ တိုက်ဆိုင်စစ်ဆေးသည် (Match)။

```
ip prefix-list CUSTOMER-NETS seq 10 permit 172.16.0.0/16 le 24
ip prefix-list CUSTOMER-NETS seq 20 permit 10.0.0.0/8 le 24
ip prefix-list NO-BOGONS     seq 10 deny  10.0.0.0/8 le 32
ip prefix-list NO-BOGONS     seq 20 permit 0.0.0.0/0 le 24
```

Length modifiers များက အဓိက အလုပ်လုပ်ဆောင်ပေးသည် -

| Modifier | မည်သည့်အရာနှင့် ကိုက်ညီသနည်း |
|---|---|
| *(မပါရှိပါ)* | ထို prefix၊ ထို length အတိအကျ |
| `le 24` | ထို prefix၊ အများဆုံး /24 အထိ (အရှည် /24 ထက်မပိုစေရ) |
| `ge 25` | ထို prefix၊ /25 နှင့် အထက် ပိုမိုရှည်လျားသော subnets များ |
| `ge 8 le 24` | /8 မှ /24 အကြား |

`permit 0.0.0.0/0` သည် default route တစ်ခုတည်းနှင့်သာ ကိုက်ညီသည်။ `permit 0.0.0.0/0 le 32` မှာမူ **အရာအားလုံး** နှင့် ကိုက်ညီသည် — ဤကွဲပြားချက်သည် လက်တွေ့လောကတွင် ကြီးမားသော ပြတ်တောက်မှု (outages) များကို ဖြစ်ပေါ်စေခဲ့ဖူးသည်။

!!! warning "အဆုံးတွင် Implicit Deny ပါရှိသည်"
    စစ်ဆေးချက်များနှင့် မကိုက်ညီသော မည်သည့်အရာကိုမဆို ငြင်းပယ် (deny) သည်။ မိမိ customers များကို permit ပေးပြီး ကျန်အရာမပါရှိသော prefix list သည် အခြားအရာအားလုံးကို အသံတိတ် drop လုပ်ပစ်မည်ဖြစ်သည် — များသောအားဖြင့် ရည်ရွယ်ချက်ရှိရှိ ပြုလုပ်ခြင်းဖြစ်သော်လည်း မတော်တဆဖြစ်ပါက ကပ်ဘေးတစ်ခု ဖြစ်သွားနိုင်သည်။

---

## Route Maps — Policy Engine အလုပ်လုပ်ပုံ

နံပါတ်တပ်ထားသော clauses များကို အစဉ်လိုက် စစ်ဆေးသည်။ ပထမဆုံး ကိုက်ညီမှု (first match) က အနိုင်ရပြီး ထိုနေရာတွင် စစ်ဆေးမှု ရပ်တန့်သွားသည်။

```
route-map CUSTOMER-IN deny 10
 match ip address prefix-list BOGONS

route-map CUSTOMER-IN permit 20
 match ip address prefix-list CUSTOMER-NETS
 set local-preference 200
 set community 65001:100

route-map CUSTOMER-IN deny 30
```

အဓိပ္ပာယ်မှာ- Bogons များကို drop ပစ်ပါ; Customer prefixes များကို လက်ခံပြီး attributes သတ်မှတ်ပါ; ကျန်အရာအားလုံးကို drop ပစ်ပါ။

| Clause | အဓိပ္ပာယ် |
|---|---|
| `permit` + match + set | ကိုက်ညီသော routes များကို လက်ခံပြီး attributes များကို သတ်မှတ်သည် |
| Match မပါသော `permit` | **အရာအားလုံး** နှင့် ကိုက်ညီသည် |
| `deny` + match | ကိုက်ညီသော routes များကို drop ပစ်သည် |
| *(Map ၏ အဆုံး)* | **Implicit deny** (မကိုက်ညီပါက drop ဖြစ်သည်) |

Neighbour တစ်ခုစီနှင့် လားရာလမ်းကြောင်းတစ်ခုစီအလိုက် သတ်မှတ်သည် -

```
router bgp 65001
 neighbor 10.0.13.3 route-map CUSTOMER-IN in
 neighbor 10.0.13.3 route-map CUSTOMER-OUT out
```

!!! danger "ကိုက်ညီမှုမရှိသော Route-map သည် အရာအားလုံးကို Deny လုပ်သည်"
    အဆုံးတွင် `permit` clause ထည့်ရန် မေ့လျော့သွားပါက routing table တစ်ခုလုံးကို drop လုပ်ပစ်မည် ဖြစ်သည်။ မပြီးပြတ်သေးသော route-map တစ်ခုကို production peer ပေါ်တွင် သတ်မှတ်လိုက်ခြင်းသည် ထို session ၏ routes အရေအတွက်ကို သုညသို့ ချက်ချင်း ကျဆင်းသွားစေသည်။

    Lab တွင် filters များကို အရင်စမ်းသပ်ပါ၊ ပြီးနောက် `show ip bgp neighbors <ip> received-routes` နှင့် routing table ထဲရှိ အခြေအနေကို အမြဲတမ်း နှိုင်းယှဉ်စစ်ဆေးပါ။

---

## Communities အသုံးပြုပုံ

Routers အချင်းချင်းကြားနှင့် အဖွဲ့အစည်းများအကြား policy ရည်ရွယ်ချက်များကို သယ်ဆောင်ပေးသော Tags များ ဖြစ်ကြသည်။

```
ip community-list standard CUSTOMER permit 65001:100

route-map PREFER permit 10
 match community CUSTOMER
 set local-preference 200
```

ထုတ်လွှင့်ပေးရန် အတိအလင်း သတ်မှတ်ပါ — Router အများစုသည် default အားဖြင့် မပို့ပါ -

```
neighbor 10.0.13.3 send-community
```

**စနစ်တကျ ကြီးထွားနိုင်သော စံပုံစံ (The pattern that scales):** Ingress နယ်စပ်တွင် Tag တွဲကပ်ပါ၊ အခြားနေရာအားလုံးတွင် ထို tag အပေါ် မူတည်၍ အရေးယူဆောင်ရွက်ပါ။

```
route-map FROM-CUSTOMER permit 10
 set community 65001:100      ! ဒါ Customer ဆီက လာတယ်
!
route-map FROM-PEER permit 10
 set community 65001:200      ! ဒါ Settlement-free peer ဆီက လာတယ်
!
route-map FROM-TRANSIT permit 10
 set community 65001:300      ! ဒါ အခပေး Transit provider ဆီက လာတယ်
```

ထို့နောက် အခြားသော policy တိုင်းသည် route မည်သည့်နေရာမှ လာသည်ကို အစမှ ပြန်လည်ရှာဖွေစရာမလိုဘဲ communities များကိုသာ match ပြုလုပ်သွားမည် ဖြစ်သည်။ Customer အသစ်တစ်ဦး ထပ်တိုးလာပါက tag တစ်ခုသာ သတ်မှတ်ပေးရုံဖြစ်ပြီး route-map တိုင်းကို လိုက်လံပြင်ဆင်စရာ မလိုတော့ပေ — ဤသည်မှာ လက်တွေ့ကွန်ရက်ကြီးများကို ထိန်းသိမ်းရလွယ်ကူစေသော နည်းလမ်းဖြစ်သည်။

Providers များသည် ၎င်းတို့ထံ ကြေညာရာတွင် သင်သတ်မှတ်နိုင်သော communities များကို ထုတ်ပြန်ပေးထားလေ့ရှိသည် — "local-pref 80 သတ်မှတ်ရန်"၊ "AS X ထံ မကြေညာရန်"၊ "Peer Y ဆီ နှစ်ကြိမ် prepend လုပ်ရန်" စသည်တို့ ဖြစ်သည်။ ၎င်းသည် prepending က အကြမ်းဖျင်းသာ တွန်းပို့ပေးနိုင်ချိန်တွင် Inbound traffic အပေါ် တိကျသော ထိန်းချုပ်မှုကို ရရှိစေသည်။

---

## AS-Path Filtering စနစ်

Regex (Regular Expressions) အသုံးပြု၍ path ကို တိုက်ဆိုင်စစ်ဆေးသည် -

```
ip as-path access-list 1 permit ^$              # locally originated သာလျှင်
ip as-path access-list 2 permit ^65002$         # AS 65002 ထံမှ တိုက်ရိုက်လာသည်
ip as-path access-list 3 permit ^65002_         # 65002 က စတင်ထုတ်လွှင့်သည်၊ အကွာအဝေးမရွေး
ip as-path access-list 4 deny   _65003_         # 65003 ကို ဖြတ်သန်းလာသော မည်သည့် route မဆို
```

| Regex | မည်သည့်အရာနှင့် ကိုက်ညီသနည်း |
|---|---|
| `^$` | အလွတ်ဖြစ်နေသော path — မိမိကိုယ်ပိုင် routes များသာလျှင် |
| `^65002$` | တိတိကျကျ AS တစ်ခုတည်း |
| `^65002_` | 65002 ဖြင့် စတင်သော path |
| `_65003_` | လမ်းကြောင်း၏ မည်သည့်နေရာတွင်မဆို 65003 ပါဝင်နေခြင်း |

`^$` သည် အလွန်အရေးကြီးပါသည်- **၎င်းသည် customer တစ်ဦးက "ငါ့ကိုယ်ပိုင် prefixes တွေကိုသာ ကြေညာပေးပါ၊ ငါ့ကို transit အဖြစ် မသုံးပါနဲ့" ဟု ပြောဆိုသည့် နည်းလမ်းဖြစ်သည်**။ မိမိ၏ upstream providers များထံ ထွက်ခွာသည့် Outbound filter တွင် ၎င်းကို အသုံးချခြင်းဖြင့် မိမိကွန်ရက်သည် မတော်တဆ transit network ဖြစ်သွားခြင်းမှ ကာကွယ်ပေးသည် — ၎င်းအမှားသည် ကမ္ဘာလုံးဆိုင်ရာ အင်တာနက်ပြတ်တောက်မှုများစွာ၏ အဓိကလက်သည် ဖြစ်ခဲ့သည်။

---

## လုပ်ငန်းခွင် လုံခြုံရေးဆိုင်ရာ ထိန်းချုပ်မှုများ (Operational Safety)

Peering ချိတ်ဆက်မှုတစ်ခုကြောင့် မိမိကွန်ရက် ပြိုလဲမသွားစေရန် ကာကွယ်ပေးသည့် ထိန်းချုပ်မှုများ ဖြစ်သည်။

### Maximum Prefix

```
neighbor 10.0.13.3 maximum-routes 100000 warning-limit 90000
```

Peer တစ်ခုက အင်တာနက် full table တစ်ခုလုံးကို သင့်ထံ မှားယွင်းယိုစိမ့်ပို့ဆောင်လာပါက memory ကုန်ခမ်းသွားပြီး sessions အားလုံး ပြုတ်ကျသွားနိုင်သည်။ Max-prefix သည် ကွန်ရက်တစ်ခုလုံး ပြုတ်ကျမည့်အစား **ထို peer တစ်ခုတည်း၏** session ကို ချက်ချင်း ပိတ်သိမ်းဖြတ်တောက်လိုက်သည်။

**၎င်းကို eBGP peer တိုင်းတွင် သတ်မှတ်ထားပါ။** Prefixes ၁၀ ခုသာ ပို့မည်ဟု မျှော်လင့်ထားသော customer တစ်ဦးကို ထိုပမာဏအနီးတွင် ကန့်သတ်ထားသင့်ပြီး တစ်သန်းအထိ မထားသင့်ပေ။

### GTSM — ebgp-multihop ထက် ပိုမိုလုံခြုံသော စနစ်

eBGP သည် တိုက်ရိုက်ချိတ်ဆက်ထားသည်ဟု ယူဆကာ default TTL 1 ကို အသုံးပြုသည်။ Multihop peering သည် `ebgp-multihop` ကို သုံးရပြီး ထိုကာကွယ်မှုကို အားနည်းစေသည်။

**GTSM** (Generalized TTL Security Mechanism) သည် စစ်ဆေးမှုကို ပြောင်းပြန်လှန်လိုက်သည် — "TTL သည် hop တစ်ခု ခံနိုင်ရမည်" ဟူသော စစ်ဆေးမှုအစား ရောက်ရှိလာသော packet ၏ TTL သည် *အလွန်မြင့်မားရမည်* ဟု သတ်မှတ်သည် (အနီးနားရှိ sender သာလျှင် ဤသို့ ပေးပို့နိုင်သည်) -

```
neighbor 10.0.13.3 ttl maximum-hops 1
```

အဝေးမှ လှမ်းတိုက်ခိုက်သူ၏ packet များသည် နိမ့်ကျသော TTL ဖြင့် ရောက်ရှိလာမည်ဖြစ်ပြီး BGP က process မလုပ်မီ hardware အဆင့်မှာပင် drop ပစ်လိုက်သည်။

### BFD

BGP timers များကို နုနယ်မသွားစေဘဲ sub-second အဆင့် လျင်မြန်စွာ ပြတ်တောက်မှုကို သိရှိနိုင်ခြင်း -

```
neighbor 10.0.13.3 bfd
```

BFD သည် မီလီစက္ကန့်ပိုင်းအတွင်း ပြတ်တောက်မှုကို သိရှိပြီး BGP အား neighbour ကို ချက်ချင်းဖြတ်တောက်ရန် ပြောပြသည် — ယာယီ ကွန်ရက်ကြပ်တည်းချိန်များတွင် session ပြုတ်ကျနိုင်ခြေရှိသော ကြမ်းတမ်းသည့် hold timers များထက် များစွာ ပိုမိုကောင်းမွန်သည်။

### Dampening

ထပ်ခါတလဲလဲ flap ဖြစ်နေသော prefix တစ်ခုအား အချိန်တိုးမြင့် ဒဏ်ခတ်မှုဖြင့် ခေတ္တ suppress လုပ်ထားခြင်း (ဖိနှိပ်တားဆီးခြင်း) ဖြစ်သည်။

၎င်းကို သတိထား၍ သုံးပါ။ Aggressive ဖြစ်လွန်းသော dampening ကို တစ်ချိန်က တွင်ကျယ်စွာ သုံးခဲ့ကြသော်လည်း နောက်ပိုင်းတွင် ပြန်လည်ရုပ်သိမ်းခဲ့ကြသည် — တိုတောင်းသော မတည်ငြိမ်မှုလေးတစ်ခုအပြီးတွင် ဒဏ်ခတ်မှုများကြောင့် ပုံမှန်ကောင်းမွန်သော prefixes များ နာရီပေါင်းများစွာ ပိတ်မိနေတတ်ပြီး flap ဖြစ်ရုံထက် ပိုမိုဆိုးရွားသော ပြတ်တောက်မှုများကို ဖြစ်ပေါ်စေခဲ့သည်။

### Soft Reconfiguration နှင့် Route Refresh

Inbound policy တစ်ခုကို ပြောင်းလဲလိုက်ခြင်းဆိုသည်မှာ လက်ခံရရှိပြီးသား routes များကို ပြန်လည် စစ်ဆေးသုံးသပ်ရမည်ဟု အဓိပ္ပာယ်ရသည်။

```
clear ip bgp 10.0.13.3 soft in       # route refresh — peer အား routes များကို ပြန်လည်ပို့ပေးရန် တောင်းဆိုသည်
```

ခေတ်သစ် router များသည် **route refresh capability** ကို ညှိနှိုင်းကြသောကြောင့် ဤ command သည် session မပြတ်တောက်ဘဲ အလုပ်ဖြစ်သည် (non-disruptive)။ ရှေးဟောင်းနည်းလမ်းဖြစ်သည့် `soft-reconfiguration inbound` သည် memory သုံးစွဲ၍ unfiltered copy တစ်ခုကို local တွင် သိမ်းထားရသဖြင့် ယခုအခါ သုံးရန် မလိုအပ်တော့ပေ။

**Production router ပေါ်တွင် `clear ip bgp *` ကို ဘယ်တော့မှ မ run ပါနှင့်။** ၎င်းသည် sessions အားလုံးကို ဖြတ်တောက်ပြီး table တစ်ခုလုံးကို အစမှ ပြန်လည် converge လုပ်စေသည် — တစ်ခါတစ်ရံ မဖြစ်မနေ သုံးရသော်လည်း ပေါ့ပေါ့ဆဆ ဘယ်တော့မှ မသုံးသင့်ပေ။

---

## စနစ်တကျ ပြည့်စုံသော eBGP Template

```
router bgp 65001
 neighbor 10.0.13.3 remote-as 65002
 neighbor 10.0.13.3 description Transit-ProviderA
 neighbor 10.0.13.3 maximum-routes 1000000 warning-limit 900000
 neighbor 10.0.13.3 ttl maximum-hops 1
 neighbor 10.0.13.3 bfd
 neighbor 10.0.13.3 send-community
 address-family ipv4
  neighbor 10.0.13.3 activate
  neighbor 10.0.13.3 route-map TRANSIT-IN in
  neighbor 10.0.13.3 route-map TRANSIT-OUT out
```

!!! tip "လမ်းကြောင်း နှစ်ဖက်စလုံးအတွက် အမြဲတမ်း သတ်မှတ်ပါ"
    eBGP peer တိုင်းတွင် Inbound **နှင့်** Outbound policy နှစ်မျိုးစလုံး အမြဲ ရှိနေရမည်။ Inbound သည် ၎င်းတို့ပေးပို့မည့် အန္တရာယ်များမှ သင့်ကို ကာကွယ်ပေးသည်; Outbound သည် သင်က မတော်တဆ ကြေညာမိမည့် အမှားများမှ အခြားသူများကို ကာကွယ်ပေးသည်။

    ကြီးမားသော BGP ပြဿနာအများစုသည် Outbound filter ကျန်ခဲ့ခြင်းကြောင့် ဖြစ်သည် — Provider တစ်ခုထံမှ သင်ယူရရှိသော routes များကို အခြား provider တစ်ခုထံ မတော်တဆ ပြန်လည်ကြေညာမိပြီး မိမိမခံနိုင်သော traffic များအတွက် transit network အဖြစ် မတော်တဆ ရောက်ရှိသွားခြင်း ဖြစ်သည်။

---

**နောက်တစ်ခု:** [iBGP ကို ချဲ့ထွင်ခြင်း (Scaling iBGP) →](05-scaling.md)
