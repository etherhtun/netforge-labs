# အဆင့် ၄ · BGP EVPN နှင့် Data Center ကိုယ်တိုင်စစ်ဆေးနိုင်သော အင်တာဗျူး မေးခွန်းများ {: #phase-4-bgp-evpn-datacenter-interview-questions }

Google စတိုင် Datacenter Infrastructure နှင့် EVPN အင်တာဗျူး မေးခွန်းများဖြင့် သင်၏ နားလည်သဘောပေါက်မှုကို စစ်ဆေးစမ်းသပ်ကြည့်ပါ။

---

### မေးခွန်း ၁: BGP EVPN Route အမျိုးအစားများ ၁၊ ၂၊ ၃၊ ၄၊ နှင့် ၅ ဆိုသည်မှာ အဘယ်နည်း။ {: #q1-what-are-bgp-evpn-route-types }
**အဖြေ:**
- **Route Type 1 (Ethernet Auto-Discovery)**: Ethernet Segment ရောက်ရှိနိုင်မှုကို ကြေညာသည်၊ fast failover (Mass Withdraw) နှင့် ESI Split-Horizon label ဖြန့်ဝေမှုအတွက် အသုံးပြုသည်။
- **Route Type 2 (MAC/IP Advertisement)**: Host MAC address များနှင့် ရွေးချယ်နိုင်သော IPv4/IPv6 host route များကို ကြေညာပြီး ARP suppression နှင့် host ရောက်ရှိနိုင်မှုအတွက် သုံးသည်။
- **Route Type 3 (Inclusive Multicast Ethernet Tag - IMET)**: BUM (Broadcast, Unknown Unicast, Multicast) traffic အတွက် headend replication tunnel များကို တည်ဆောက်ပေးသည်။
- **Route Type 4 (Ethernet Segment Route)**: All-Active ESI multihoming အတွက် PE discovery နှင့် Designated Forwarder (DF) ရွေးကောက်ပွဲကို ပြုလုပ်ပေးသည်။
- **Route Type 5 (IP Prefix Route)**: VRF များတစ်လျှောက် inter-subnet routing အတွက် subnet prefix များ (ဥပမာ `10.100.0.0/16`) ကို ကြေညာပေးသည်။

---

### မေးခွန်း ၂: Symmetric IRB နှင့် Asymmetric IRB အကြား ခြားနားချက်မှာ အဘယ်နည်း။ {: #q2-symmetric-vs-asymmetric-irb }
**အဖြေ:**
- **Asymmetric IRB**: Ingress VTEP သည် source VNI မှ destination VNI သို့ local အတိုင်း route လုပ်ပေးပြီး၊ destination VNI ပေါ်မှတစ်ဆင့် egress VTEP ဆီသို့ bridge လုပ်ပေးသည်။ Egress VTEP တွင် tenant VNI အားလုံးကို မဖြစ်မနေ configure လုပ်ထားရသည်။
- **Symmetric IRB**: Ingress VTEP သည် traffic ကို မျှဝေသုံးစွဲထားသော **L3 VRF VNI** ထဲသို့ route လုပ်ကာ encapsulate လုပ်ပြီး egress VTEP သို့ ပေးပို့သည်။ Egress VTEP သည် L3 VNI ပေါ်တွင် packet ကို လက်ခံရရှိပြီး destination VNI ထဲသို့ route ပြုလုပ်သည်။ Multi-tenant fabric များတွင် များစွာ ပိုမိုစကေးချဲ့နိုင်သည်။

---

### မေးခွန်း ၃: All-Active Multihoming အခြေအနေတွင် EVPN သည် loop မဖြစ်အောင် မည်သို့ ကာကွယ်သနည်း။ {: #q3-evpn-loop-prevention-all-active-multihoming }
**အဖြေ:**
EVPN သည် EVPN Route Type 1 (Auto-Discovery Route) မှတစ်ဆင့် **Split-Horizon Filtering** ကို အသုံးပြုသည်။ Leaf node တစ်ခုသည် multihomed host တစ်ခုထံမှ BUM traffic ကို encapsulate လုပ်သောအခါ **ESI Label** တစ်ခု ပူးတွဲထည့်သွင်းပေးသည်။ Peer multihomed Leaf သည် အဆိုပါ packet ကို လက်ခံရရှိသောအခါ ESI label ကို စစ်ဆေးသည်။ ၎င်းသည် ထို segment အတွက် မိမိ၏ local ESI နှင့် ကိုက်ညီနေသောကြောင့် host ဆီသို့ မပို့ဘဲ packet ကို drop ပစ်လိုက်သဖြင့် loop မဖြစ်အောင် ကာကွယ်ပေးသည်။

---

### မေးခွန်း ၄: EVPN All-Active Multihoming တွင် BUM traffic နှစ်ခါထပ် ပေးပို့မိခြင်းကို မည်သို့ ကာကွယ်သနည်း။ {: #q4-preventing-bum-duplicate-delivery }
**အဖြေ:**
**Designated Forwarder (DF) Election** (EVPN Route Type 4) ကို အသုံးပြုခြင်းဖြင့် ဖြစ်သည်။ တူညီသော ESI နှင့် ချိတ်ဆက်ထားသော Leaf များအားလုံးသည် Route Type 4 message များကို ဖလှယ်ကြသည်။ ၎င်းတို့သည် VLAN တစ်ခုချင်းစီအတွက် Designated Forwarder တစ်ခုတည်းကို ရွေးချယ်ရန် modulo algorithm (ဥပမာ `VLAN ID mod N`) ကို အသုံးပြုကြသည်။ DF ဖြစ်သော Leaf တစ်ခုတည်းသာ multihomed CE စက်ဆီသို့ BUM traffic ကို ပေးပို့ခွင့်ရှိသည်။ Non-DF node များသည် ထို segment ဆီသို့ BUM ထွက်ပေါက်ကို ပိတ်ထားပေးသည်။

---

### မေးခွန်း ၅: EVPN ရှိ MAC Mobility ဆိုသည်မှာ အဘယ်နည်း၊ ၎င်းသည် virtual machine ရွှေ့ပြောင်းခြင်းကြောင့် ဖြစ်ပေါ်တတ်သော loop များကို မည်သို့ ဖြေရှင်းပေးသနည်း။ {: #q5-what-is-mac-mobility }
**အဖြေ:**
VM (MAC address) တစ်ခုသည် Leaf1 မှ Leaf2 သို့ ရွှေ့ပြောင်းသွားသောအခါ Leaf2 သည် MAC ကို local အနေဖြင့် သိရှိပြီး EVPN Route Type 2 အသစ်တစ်ခုကို ကြေညာသည်။ အခြား node အားလုံးအနေဖြင့် ၎င်းသည် network loop/flap မဟုတ်ဘဲ အမှန်တကယ် ရွှေ့ပြောင်းသွားခြင်းဖြစ်ကြောင်း သေချာစေရန် EVPN သည် **MAC Mobility Sequence Number** extended community ကို အသုံးပြုသည်။
- Leaf1 က မူလတွင် ထို MAC ကို Sequence `0` ဖြင့် ကြေညာခဲ့သည်။
- Leaf2 က ရွှေ့ပြောင်းသွားသော MAC ကို Sequence `1` ဖြင့် ကြေညာသည်။
- Leaf1 က Sequence `1` ကို လက်ခံရရှိသောအခါ host သည် ရွှေ့ပြောင်းသွားပြီဖြစ်ကြောင်း သဘောပေါက်ပြီး မိမိ၏ Route Type 2 ကို ပြန်လည်ရုပ်သိမ်း (withdraw) ကာ local MAC ကို ဖျက်ပစ်လိုက်သည်။ အကယ်၍ MAC သည် ရှေ့နောက် အလွန်လျင်မြန်စွာ ကူးပြောင်းနေပါက MAC duplication/flap dampening စနစ် စတင်လည်ပတ်ပါမည်။

---

### မေးခွန်း ၆: EVPN fabric များတွင် ARP Suppression သည် အဘယ်ကြောင့် အရေးကြီးသနည်း။ {: #q6-why-is-arp-suppression-important }
**အဖြေ:**
VXLAN fabric တစ်လျှောက် ဆွဲဆန့်ထားသော ကြီးမားသော subnet တစ်ခုတွင် ARP broadcasts (BUM traffic) များသည် fabric bandwidth နှင့် CPU ကို အလွန်အမင်း ကုန်ခမ်းစေသည်။ EVPN **Proxy ARP / ARP Suppression** သည် ingress Leaf အား ARP request ကို ကြားဖြတ်ဖမ်းယူခွင့် ပြုသည်။ အကယ်၍ Leaf သည် EVPN BGP database (Route Type 2) မှတစ်ဆင့် target ၏ MAC address ကို သိရှိပြီးဖြစ်ပါက local host ဆီသို့ တိုက်ရိုက် ပြန်လည်ဖြေကြားပေးသဖြင့် broadcast traffic သည် VXLAN fabric ထဲသို့ ဘယ်သောအခါမျှ ဝင်ရောက်မလာအောင် ဖိနှိပ်ထိန်းချုပ်ပေးပါသည်။
