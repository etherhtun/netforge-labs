# အင်တာဗျူး မေးခွန်းများ {: #interview-questions }

ခေါင်းစဉ်အလိုက် လွယ်ကူရာမှ ခက်ခဲရာသို့ စုစည်းထားသော ကိုယ်တိုင်စစ်ဆေးနိုင်သည့် မေးခွန်းဘဏ်ဖြစ်ပါသည်။ **အဖြေများကို ဖျောက်ထားပါသည်** — အရင်ဆုံး အသံထွက်၍ ဖြေဆိုကြည့်ပါ၊ ထို့နောက် အဖြေမှန်ကို နှိပ်၍ စစ်ဆေးပါ။ အကယ်၍ သင်သည် ⭐ ပြထားသော မေးခွန်းများကို ရှင်းလင်းပြတ်သားစွာ ဖြေဆိုနိုင်ပါက Data Center ဒီဇိုင်းဆိုင်ရာ အင်တာဗျူးအတွက် အလွန်ကောင်းမွန်သော အနေအထားသို့ ရောက်ရှိနေပြီ ဖြစ်ပါသည်။

---

## အခြေခံ သဘောတရားများ {: #fundamentals }

??? question "VLAN များ မဖြေရှင်းနိုင်သော မည်သည့်ပြဿနာကို VXLAN က ဖြေရှင်းပေးသနည်း။"
    VLAN များသည် segment ၄၀၉၄ ခုသာ ကန့်သတ်ထားရှိပြီး (12-bit tag) အရန် link များကို ပိတ်ထားရသော spanning tree အပေါ်တွင် မှီခိုနေရသည်။ VXLAN သည် segment ပေါင်း ~၁၆ သန်း (24-bit VNI) ပေးစွမ်းနိုင်ပြီး **routed** L3 underlay ပေါ်တွင် L2 ကို လည်ပတ်စေသောကြောင့် link အားလုံး တက်ကြွနေပြီး (ECMP) L2 segment များကို fabric တစ်ခုလုံးအထိ ဆွဲဆန့်နိုင်စေပါသည်။

??? question "⭐ တစ်ကြောင်းစီဖြင့် ရှင်းပြပါ: VXLAN နှင့် EVPN တို့သည် မည်သည့်အရာကို လုပ်ဆောင်သနည်း။"
    **VXLAN** သည် data plane ဖြစ်သည် — ၎င်းသည် L2 frame များကို UDP/IP ထဲသို့ encapsulate လုပ်၍ L3 network တစ်လျှောက် သယ်ဆောင်ပေးသည်။ **EVPN** သည် control plane ဖြစ်သည် — MAC/IP တစ်ခုချင်းစီ မည်သည့်နေရာတွင် ရှိနေကြောင်းကို ကြေညာပေးသည့် BGP address family ဖြစ်သောကြောင့် tunnel များကို flooding အစား သိရှိထားသော ဗဟုသုတဖြင့် တည်ဆောက်စေသည်။

??? question "VTEP ဆိုသည်မှာ အဘယ်နည်း။"
    VXLAN Tunnel EndPoint — Tenant frame များကို VXLAN အဖြစ် encapsulate ပြုလုပ်ပေးပြီး အဝေးဘက်ခြမ်းတွင် ပြန်လည်ဖောက်ထုတ်ပေးသော ကိရိယာ (spine-leaf တွင် leaf) ဖြစ်သည်။ ၎င်း၏ တစ်ဖက်ခြမ်းတွင် tenant VLAN များရှိပြီး အခြားတစ်ဖက်ခြမ်းတွင် loopback (tunnel source) ရှိသည်။

## Underlay {: #underlay }

??? question "Underlay ၏ တစ်ခုတည်းသော တာဝန်မှာ အဘယ်နည်း။"
    VTEP loopback များအကြား တူညီသောစရိတ်မျှ လမ်းကြောင်းများစွာ (equal-cost multipath) ဖြင့် ရောက်ရှိနိုင်စွမ်းကို ပေးဆောင်ရန် ဖြစ်သည်။ Tenant နှင့် သက်ဆိုင်သော မည်သည့်အရာမှ underlay ထဲတွင် မရှိပါ။

??? question "Underlay ကို မည်သည့် protocol များဖြင့် run နိုင်သနည်း၊ အားသာချက်/အားနည်းချက်များမှာ အဘယ်နည်း။"
    OSPF၊ IS-IS၊ သို့မဟုတ် eBGP။ OSPF/IS-IS တို့သည် ရိုးရှင်းသော IGP များဖြစ်ပြီး လျင်မြန်စွာ တည်ဆောက်နိုင်သည်။ eBGP သည် စကေးချဲ့ရာတွင် ပိုမိုကောင်းမွန်ပြီး protocol တစ်ခုတည်း (BGP) ဖြင့် underlay ရော overlay ပါ နှစ်မျိုးလုံးကို လုပ်ဆောင်နိုင်သော်လည်း link တစ်ခုချင်းစီအလိုက် AS/peer configuration ပိုများသည်။

??? question "Fabric link များပေါ်တွင် /31 ကို အဘယ်ကြောင့် အသုံးပြုသနည်း။"
    Point-to-point link များသည် လိပ်စာနှစ်ခုသာ လိုအပ်သည်။ /31 သည် လိပ်စာအတိအကျ ၂ ခုကိုသာ အသုံးပြုပြီး လုံးဝလေလွင့်မှုမရှိစေပါ၊ link တစ်ခုလျှင် လိပ်စာ ၂ ခုစီ အလဟဿဖြစ်စေသော /30 ထက် သာလွန်သည်။

??? question "⭐ Underlay သည် Jumbo MTU ကို အဘယ်ကြောင့် မဖြစ်မနေ အသုံးပြုရမည်နည်း။"
    VXLAN သည် header အတွက် ~50 bytes ခန့် ထပ်တိုးစေသည်။ 1500-byte tenant frame တစ်ခုသည် ဝါယာကြိုးပေါ်တွင် ~1550 bytes ဖြစ်သွားမည်ဖြစ်ရာ သမားရိုးကျ 1500 MTU သည် ၎င်းကို drop ဖြစ်စေခြင်း သို့မဟုတ် fragment ကွဲသွားစေခြင်း ဖြစ်စေသည်။ ထို့ကြောင့် encapsulated packet အလွယ်တကူ ဆန့်ဝင်စေရန် fabric link များသည် 9000/9216 ကို အသုံးပြုရသည်။

## VXLAN Data Plane {: #vxlan-data-plane }

??? question "VXLAN မှ ထပ်ပေါင်းထည့်လိုက်သော header များကို ဖော်ပြပါ၊ Spines များသည် မည်သည့် header ပေါ်တွင် လမ်းကြောင်းပေးသနည်း။"
    Outer Ethernet, Outer IP, UDP, VXLAN (VNI) တို့ ဖြစ်သည်။ **Outer IP** (source VTEP loopback → dest VTEP loopback) သည် underlay/spines များက လမ်းကြောင်းရှာဖွေသော အချက်အလက် ဖြစ်သည် — spines များသည် အတွင်းပိုင်း frame ကို မည်သည့်အခါမျှ စစ်ဆေးခြင်း မပြုပါ။

??? question "VXLAN UDP destination port နံပါတ်မှာ အဘယ်နည်း။"
    ၄၇၈၉ (IANA စံနှုန်း) ဖြစ်သည်။ ၎င်းသည် လက်ခံရရှိသော VTEP အား "ဤအရာသည် VXLAN ဖြစ်သည်" ဟု အသိပေးသည်။

??? question "⭐ Outer UDP source port သည် အဘယ်ကြောင့် အရေးကြီးသနည်း။"
    ၎င်းသည် တကယ့် port အစစ်မဟုတ်ပါ — VTEP သည် ၎င်းအား **အတွင်းပိုင်း flow ၏ hash တန်ဖိုး** အဖြစ် သတ်မှတ်ပေးသည်။ ၎င်းသည် underlay အား flow တစ်ခုချင်းစီအလိုက် entropy ပေးစွမ်းသောကြောင့် ECMP သည် spine link အားလုံးပေါ်တွင် မတူညီသော flow များကို ညီမျှစွာ ဖြန့်ဝေပေးနိုင်သည် (load balancing ဖြစ်ပေါ်စေသည်)။

??? question "BUM traffic ဆိုသည်မှာ အဘယ်နည်း၊ EVPN-VXLAN တွင် ၎င်းကို မည်သို့ ကိုင်တွယ်သနည်း။"
    Broadcast, Unknown-unicast, Multicast ဖြစ်သည်။ EVPN သည် ၎င်းအား default အားဖြင့် **ingress replication** (head-end replication) ဖြင့် ကိုင်တွယ်သည်: Ingress VTEP သည် ထို VNI ရှိ remote VTEP တစ်ခုစီထံသို့ unicast မိတ္တူတစ်ခုစီ ပေးပို့သည်။ Replication list ကို **Type-3** route များမှ တည်ဆောက်သည်။ (အခြားရွေးချယ်စရာမှာ underlay multicast ဖြစ်သည်)။

??? question "L2VNI နှင့် L3VNI အကြား ခြားနားချက်မှာ အဘယ်နည်း။"
    L2VNI သည် VLAN တစ်ခုနှင့် ချိတ်ဆက်ပြီး **bridging** အတွက် အသုံးပြုသည် (leaf များတစ်လျှောက် တူညီသော subnet)။ L3VNI သည် VRF တစ်ခုနှင့် ချိတ်ဆက်ပြီး subnet များအကြား / ပြင်ပသို့ **routing** ပြုလုပ်ရန် အသုံးပြုသည် (Type-5 routes, IRB)။

## EVPN Control Plane {: #evpn-control-plane }

??? question "EVPN သည် မည်သည့်အရာကို မည်သည့်အရာဖြင့် အစားထိုးသနည်း။"
    ၎င်းသည် L2 flood-and-learn ကို BGP ကြေညာခြင်းဖြင့် အစားထိုးသည်: VTEP များသည် flooding ဖြင့် လိုက်ရှာမည့်အစား မိမိတို့၏ local MACs/IPs များကို အချင်းချင်း ကြေညာကြသည်။

??? question "EVPN ကို မည်သည့် protocol ထဲတွင် မည်သည့်ပုံစံဖြင့် သယ်ဆောင်သနည်း။"
    MP-BGP ထဲတွင် address family တစ်ခုအနေဖြင့် (AFI 25 L2VPN, SAFI 70 EVPN)။ Junos တွင်: `family evpn signaling`။

??? question "⭐ Route Distinguisher နှင့် Route Target အကြား ခြားနားချက်ကို ရှင်းပြပါ။"
    **RD** သည် BGP ထဲတွင် VTEP တစ်ခုချင်းစီ၏ route များကို တစ်မူထူးခြားစေသည် (တူညီသော subnet ကို ကြေညာသော leaf နှစ်ခု မတိုက်မိစေရန်) — VTEP တစ်ခုစီအတွက် မတူညီပါ။ **RT** သည် import/export ကို ထိန်းချုပ်သော extended community ဖြစ်သည် — RT တူညီခြင်း = virtual network တစ်ခုတည်း ဖြစ်သဖြင့် VNI တစ်ခုအတွင်းရှိ VTEP များအားလုံး တူညီသော RT ကို သုံးကြသည်။ **RD = တစ်မူထူးခြားမှု (uniqueness), RT = အဖွဲ့ဝင်ဖြစ်မှု (membership)။**

??? question "ARP suppression ဆိုသည်မှာ အဘယ်နည်း၊ ၎င်းသည် မည်သို့ အထောက်အကူပြုသနည်း။"
    Local leaf သည် fabric ကို ဖြတ်သန်း၍ ARP များကို flood မလုပ်စေဘဲ မိမိ၏ EVPN (Type-2) table မှ ARP request များကို တိုက်ရိုက်ပြန်လည်ဖြေကြားပေးသည်။ ၎င်းသည် broadcast traffic ကို လျှော့ချပေးပြီး resolution ကို ပိုမိုမြန်ဆန်စေသည် — ARP သည် ingress leaf မှ အပြင်သို့ ဘယ်တော့မှ ထွက်မသွားပါ။

??? question "Overlay အတွက် iBGP vs eBGP — မည်သည့်အခါတွင် မည်သည့်အရာကို သုံးမည်နည်း။"
    iBGP: VTEP အားလုံးသည် AS တစ်ခုတည်းဖြစ်ပြီး ရိုးရှင်းသော်လည်း စကေးကြီးမားပါက full mesh သို့မဟုတ် route reflectors လိုအပ်သည် (spines များကို RRs အဖြစ်သုံးသည်)။ eBGP: Leaf တစ်ခုစီသည် သီးခြား AS ဖြစ်ပြီး စကေးချဲ့ရန် ကောင်းမွန်ကာ protocol တစ်ခုတည်းဖြင့် underlay + overlay ကို လုပ်ဆောင်နိုင်သဖြင့် ကြီးမားသော fabric များတွင် အသုံးများသည်။ Peer တစ်ခုချင်းစီအတွက် config ပိုများသည်။

## Route အမျိုးအစားများ {: #route-types }

??? question "⭐ မည်သည့် Host မှ traffic မပို့မီ မည်သည့် EVPN route အမျိုးအစားသည် ဦးစွာ ပေါ်ပေါက်လာသနည်း၊ အဘယ်ကြောင့်နည်း။"
    **Type-3 (Inclusive Multicast / IMET)** — VTEP တွင် အလုပ်လုပ်နေသော member interface ပါသည့် VNI တစ်ခု ရှိလာသည်နှင့် ကြေညာသည်။ VTEP များသည် အချင်းချင်း ရှာဖွေတွေ့ရှိရန်နှင့် BUM flood list ကို တည်ဆောက်ရန် ၎င်းကို သုံးကြသည်၊ VXLAN tunnel သည် ၎င်းကို အခြေပြု၍ ဖြစ်ပေါ်လာသည်။ Type-2 သည် host တစ်ခုကို အမှန်တကယ် သိရှိပြီးမှသာ ပေါ်ပေါက်လာသည်။

??? question "Type-2 route တစ်ခုတည်းက မည်သည့်အရာများကို ဖြစ်မြောက်စေသနည်း။"
    Remote MAC learning (မူလ VTEP ၏ tunnel သို့ ညွှန်ပြသော MAC ကို ထည့်သွင်းခြင်း) **နှင့်** IP အပိုင်းသည် ARP suppression အတွက် အထောက်အကူပြုခြင်း။ Host တစ်ခု ရွှေ့ပြောင်းသွားပါက Type-2 အသစ်သည် လျင်မြန်စွာ ပြန်လည် converge ဖြစ်စေသည်။

??? question "Type-5 route ကို မည်သည့်အချိန်တွင် လိုအပ်သနည်း။"
    Bridging ပြုလုပ်ခြင်းထက် Routing ပြုလုပ်ရန် လိုအပ်သည့်အခါ — L3VNI မှတစ်ဆင့် inter-subnet/inter-VNI routing ပြုလုပ်ခြင်း၊ ပြင်ပ prefix များသို့ ချိတ်ဆက်ခြင်း၊ သို့မဟုတ် summarisation ပြုလုပ်ခြင်းတို့အတွက် ဖြစ်သည်။ Type-5 သည် MAC မပါဝင်သော IP prefix ကို သယ်ဆောင်သည်။

??? question "Multihoming တွင် မည်သည့် route အမျိုးအစားများ ပါဝင်သနည်း။"
    Type-1 (Ethernet A-D, fast failover/aliasing အတွက်) နှင့် Type-4 (Ethernet Segment, Designated Forwarder ရွေးကောက်ပွဲအတွက်)။

## ဒီဇိုင်းနှင့် စကေးချဲ့ခြင်း {: #design-and-scale }

??? question "ရိုးရာ three-tier အစား Spine-leaf ကို အဘယ်ကြောင့် သုံးသနည်း။"
    ခန့်မှန်းရလွယ်ကူသော any-to-any latency (leaf တိုင်းသည် အခြား leaf တိုင်းနှင့် two hops သာ ကွာဝေးသည်)၊ အလျားလိုက် စကေးချဲ့နိုင်စွမ်း (leaves/spines များ ထပ်တိုးနိုင်သည်)၊ နှင့် ပိတ်ထားသော link မရှိသည့် ပြည့်ဝသော ECMP ရရှိခြင်းတို့ကြောင့် ဖြစ်သည်။

??? question "စကေးကြီးမားလာသောအခါ Overlay အတွက် Full-mesh iBGP ကို အဘယ်ကြောင့် မသုံးသင့်သနည်း။"
    Leaf $N$ ခုသည် session ပေါင်း $N(N-1)/2$ ခု လိုအပ်သဖြင့် session အရေအတွက် အဆမတန် များပြားသွားနိုင်သည်။ Leaf တစ်ခုစီသည် Spine များနှင့်သာ peer လုပ်စေရန် Spine များကို **route reflectors** အဖြစ် (သို့မဟုတ် eBGP) အသုံးပြုရမည်။

??? question "⭐ Anycast gateway ဆိုသည်မှာ အဘယ်နည်း၊ ၎င်းကို အဘယ်ကြောင့် သုံးသနည်း။"
    Subnet တစ်ခုအတွက် Leaf တိုင်းပေါ်တွင် တူညီသော gateway IP **နှင့်** MAC ကို သတ်မှတ်ထားခြင်း ဖြစ်သည်။ Host တစ်ခုသည် မည်သည့် leaf ပေါ်တွင် ရှိနေပါစေ မိမိ၏ local leaf ကို default gateway အဖြစ် အမြဲတမ်း အသုံးပြုနိုင်သောကြောင့် routing သည် အကောင်းဆုံးဖြစ်ပြီး VM ရွှေ့ပြောင်းသွားသော်လည်း gateway မပျက်စီးစေပါ။

??? question "Symmetric vs Asymmetric IRB နှိုင်းယှဉ်ချက်။"
    နှစ်မျိုးလုံးသည် inter-subnet routing ကို လုပ်ဆောင်ကြသည်။ **Symmetric** သည် မျှဝေသုံးစွဲသော L3VNI ကို သုံးပြီး ingress နှင့် egress leaf နှစ်ဖက်စလုံးတွင် route လုပ်သည် (route-bridge / bridge-route အချိုးညီသည်) — စကေးချဲ့ရန် ပိုကောင်းပြီး ခေတ်သစ် standard ဖြစ်သည်။ **Asymmetric** သည် leaf တိုင်းတွင် VNI တိုင်း ရှိနေရန် လိုအပ်သည်။ ယေဘုယျအားဖြင့် Symmetric ကို ပိုမိုရွေးချယ်ကြသည်။

## ပြဿနာဖြေရှင်းခြင်း {: #troubleshooting }

??? question "BGP-EVPN session သည် Up ဖြစ်နေသော်လည်း `bgp.evpn.0` တွင် route 0 ခုသာ ပြနေသည်။ ပထမဆုံး မည်သည့်အရာများကို စစ်ဆေးမည်နည်း။"
    VNI တစ်ခုတွင် active member မရှိသေးပါက ပုံမှန်အားဖြင့် ဤသို့ ဖြစ်တတ်သည်။ စစ်ဆေးရန်: VLAN ကို VNI နှင့် ချိတ်ဆက်ထားသလား။ ထို VLAN တွင် up ဖြစ်နေသော interface ရှိသလား။ VNI သည် extended-vni-list ထဲတွင် ပါဝင်သလား။ VTEP များကြား RTs ကိုက်ညီမှုရှိသလား။

??? question "Tunnel သည် Up ဖြစ်နေသော်လည်း Host များသည် fabric ကို ဖြတ်၍ ping မရပါ။ မည်သည့်နေရာကို ကြည့်ရှုစစ်ဆေးမည်နည်း။"
    Host နှစ်ခုလုံးအတွက် Type-2 route များ ရှိမရှိ (`show evpn database`)၊ MAC ကို remote အနေဖြင့် သိရှိထားခြင်း ရှိမရှိ (`show ethernet-switching table` → remote/DR flag)၊ RT import/export ကိုက်ညီမှု၊ Leaf နှစ်ဖက်စလုံးရှိ မှန်ကန်သော VLAN↔VNI mapping၊ နှင့် fabric link များပေါ်ရှိ MTU တို့ကို စစ်ဆေးပါ။

??? question "Ping ရသော်လည်း ကြီးမားသော data လွှဲပြောင်းမှုများ ကျရှုံးနေသည်။ မည်သည့်အကြောင်းရင်း ဖြစ်နိုင်သနည်း။"
    MTU ကြောင့် ဖြစ်သည်။ Packet သေးသေးလေးများသည် ဆန့်ဝင်သော်လည်း full-size frame များနှင့် 50 bytes ရှိသော VXLAN overhead တို့သည် 1500 underlay MTU ထက် ကျော်လွန်သွားသောကြောင့် ဖြစ်သည်။ Fabric link များပေါ်တွင် Jumbo frames များကို ဖွင့်ပေးပါ။

## Juniper ဆိုင်ရာ သီးသန့်အချက်များ {: #juniper-specific }

??? question "⭐ Junos ပေါ်တွင် VNI ကို configure လုပ်ထားသော်လည်း Type-3 route ပေါ်မလာပါ။ Bug ဖြစ်နေပါသလား။"
    မဟုတ်ပါ — **Junos သည် VLAN တွင် အမှန်တကယ် operational-up ဖြစ်နေသော member interface ရှိမှသာ Type-3 (IMET) route ကို စတင်ထုတ်ပေးပါသည်။** VLAN ထဲတွင် access port မရှိပါက flood လုပ်စရာ မရှိသောကြောင့် မည်သည့်အရာမှ မကြေညာခြင်း ဖြစ်သည်။ Access port တစ်ခု ထည့်သွင်းလိုက်သည်နှင့် Type-3 (နှင့် tunnel) ပေါ်လာပါမည်။ (Cisco NX-OS သည် VNI ကို သတ်မှတ်လိုက်သည်နှင့် ချက်ချင်းကြေညာသည် — ၎င်းသည် စနစ်နှစ်ခုကြား အမှန်တကယ် ကွဲပြားသော အပြုအမူ ဖြစ်သည်)။

??? question "Junos leaf ပေါ်တွင် VXLAN tunnel ကို source ပြုလုပ်ပေးသော interface တစ်ခုတည်းမှာ အဘယ်နည်း။"
    `set switch-options vtep-source-interface lo0.0` မှတစ်ဆင့် `lo0.0` ဖြစ်သည်။ Junos သည် router-id၊ BGP peering၊ နှင့် VTEP source အတွက် loopback တစ်ခုတည်းကိုသာ အသုံးပြုပါသည် (သီးခြား VTEP loopback သုံးသော အခြား platform များနှင့် မတူပါ)။

??? question "`show ethernet-switching table` တွင် `DR` flag သည် အဘယ်အရာကို ဆိုလိုသနည်း။"
    Dynamic + **R**emote — Physical port ပေါ်တွင် locally သိရှိထားသော MAC မဟုတ်ဘဲ VXLAN tunnel (`vtep.xxxxx`) မှတစ်ဆင့် **remote** VTEP ထံမှ dynamic အနေဖြင့် သိရှိထားသော MAC ဖြစ်သည်။

??? question "3:10.0.0.21:1::10100::10.0.0.21 ကဲ့သို့သော EVPN route ၏ အမျိုးအစားကို မည်သို့ ဖတ်ရှုမည်နည်း။"
    **ရှေ့ဆုံးဂဏန်း** သည် route အမျိုးအစား ဖြစ်သည် (ဤနေရာတွင် `3` = IMET)။ ထို့နောက် RD (`10.0.0.21:1`)၊ ထို့နောက် VNI (`10100`)၊ ထို့နောက် originator ဖြစ်သည်။ ထိုပထမဆုံးဂဏန်းကို ဖတ်ရှုခြင်းဖြင့် မည်သည့်ကြေညာချက်အမျိုးအစားဖြစ်ကြောင်း ချက်ချင်း သိရှိနိုင်သည်။
