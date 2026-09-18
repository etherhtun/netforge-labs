# အင်တာဗျူး မေးခွန်းများ — Phase 2 · BGP-DIA နှင့် Internet Edge

ဤမေးခွန်းဘဏ်သည် **Google Network Infrastructure Engineer (NIE)** နှင့် **Hyperscale Edge System Engineer** နည်းပညာ အင်တာဗျူး အခြေအနေများကို ပစ်မှတ်ထား ရေးဆွဲထားခြင်း ဖြစ်သည်။

---

## DIA Traffic Engineering နှင့် BGP Communities {: #dia-traffic-engineering }

??? question "AS_PATH length မည်မျှပင် ရှည်စေကာမူ Egress traffic ကို Provider B ထက် Provider A ဘက်သို့ အမြဲဦးစားပေး သွားလာစေရန် မည်သို့ ပြုလုပ်မည်နည်း။"
    Provider A ထံမှ လက်ခံရရှိသော inbound route advertisements များပေါ်တွင် **`LOCAL_PREF`** ကို ပိုမိုမြင့်မားသော တန်ဖိုး (ဥပမာ 150) သတ်မှတ်ပေးပါ။ `LOCAL_PREF` ကို BGP best-path decision algorithm ၏ အဆင့် ၂ တွင် စစ်ဆေးပြီး `AS_PATH` length (အဆင့် ၄) ထက် အမြဲတစေ သာလွန်အနိုင်ရရှိသည်။

??? question "Standard BGP Communities သည် 4-byte ASNs များအတွက် အဘယ်ကြောင့် ချို့ယွင်းသွားရသနည်း၊ Large Communities က ယင်းကို မည်သို့ ဖြေရှင်းပေးသနည်း။"
    Standard BGP communities သည် 32 bits (`16-bit ASN : 16-bit Value`) ကို အသုံးပြုသည်။ အကယ်၍ အဖွဲ့အစည်းတစ်ခုတွင် 32-bit 4-byte ASN (ဥပမာ Google `AS15169` သို့မဟုတ် `AS195169`) ရှိနေပါက ၎င်းသည် 16-bit ASN field အတွင်း နေရာမဆန့်တော့ပါ။ **Large Communities (RFC 8092)** သည် 96 bits (`32-bit Global Admin : 32-bit Action : 32-bit Target`) ကို ထောက်ပံ့ပေးပြီး 32-bit integers ၃ ခုအဖြစ် ပုံစံချထားသည် (`15169:1000:70`)။

??? question "Hot-Potato နှင့် Cold-Potato routing အကြား ကွာခြားချက်မှာ အဘယ်နည်း။"
    **Hot-Potato routing** သည် internal network bandwidth ကို ချွေတာရန်အတွက် egress traffic ကို အနီးဆုံးရှိ external ISP interface ထံသို့ အမြန်ဆုံး စွန့်ထုတ်ပေးအပ်ခြင်း ဖြစ်သည်။ **Cold-Potato routing** သည် traffic ကို မိမိ၏ private internal backbone (Google B4 ကဲ့သို့) ပေါ်တွင် destination နှင့် အနီးကပ်ဆုံးနေရာအထိ သယ်ဆောင်သွားပြီးမှသာ ပြင်ပသို့ လွှဲပြောင်းပေးအပ်ခြင်းဖြစ်ပြီး latency ကို အပြည့်အဝ ထိန်းချုပ်နိုင်ကာ SLA ကို အကောင်းဆုံး ဖြစ်စေသည်။

??? question "အခြေအနေတစ်ခု- Provider A နှင့် B အကြား Asymmetric routing ဖြစ်ပေါ်မှုကြောင့် Stateful firewalls များက ပြန်လည်ရောက်ရှိလာသော TCP packets များကို drop ဖြစ်စေသည်။ ယင်းကို မည်သို့ ဖြေရှင်းမည်နည်း။"
    ၁။ **Stateful Session Synchronization**: Edge ပွိုင့်များတစ်လျှောက်ရှိ stateful firewalls များကို high-speed HA synchronization links များဖြင့် cluster ပြုလုပ်ထားရှိပြီး firewall nodes အားလုံးသည် TCP session state ကို မျှဝေသိရှိစေခြင်း။
    ၂။ **Ingress Path Alignment**: Provider B ထံ ကြေညာသော outbound advertisements များပေါ်တွင် BGP Large Communities (`65003:70`) သို့မဟုတ် AS-Path Prepending (`prepend 65001 65001`) သတ်မှတ်၍ Provider B ၏ Local Preference ကို လျှော့ချစေကာ အပြန် traffic များကို Provider A မှတစ်ဆင့်သာ ပြန်ဝင်လာစေရန် ဖိအားပေးခြင်း။
    ၃။ **BGP Session Sharing / ARG**: Edge router layer တွင် Asymmetric Routing Groups (ARG) ကို အကောင်အထည်ဖော်ပြီး အပြန် traffic များကို မူလ firewall ဆီသို့ရောက်ရှိစေရန် inter-edge iBGP link ပေါ်မှတစ်ဆင့် လမ်းကြောင်းလွှဲပို့ပေးခြင်း။

---

## RPKI နှင့် BGP ကာကွယ်ရေး လုံခြုံရေး {: #rpki-bgp-security }

??? question "RPKI validation states ၃ မျိုးမှာ အဘယ်နည်း၊ Edge router တစ်ခုသည် ၎င်းတို့အပေါ် မည်သို့ တုံ့ပြန်ဆောင်ရွက်သင့်သနည်း။"
    - **`Valid`**: Prefix နှင့် origin AS သည် လက်မှတ်ရေးထိုးထားသော ROA object နှင့် ထပ်တူညီသည်။ *ပုံမှန်/မြင့်မားသော ဦးစားပေးမှုဖြင့် ခွင့်ပြုသည် (`LOCAL_PREF 120`)။*
    - **`Invalid`**: ROA ရှိသော်လည်း origin AS သို့မဟုတ် prefix length မကိုက်ညီပါ။ **BGP hijacks များကို ကာကွယ်ရန် ချက်ချင်း drop ပစ်ရမည် (`deny`)။**
    - **`NotFound`**: Global repositories များတွင် မည်သည့် ROA မျှ မတွေ့ရှိပါ။ *RPKI လက်မှတ်မထိုးရသေးသော ပုံမှန်အင်တာနက် routes များကို မတော်တဆ drop မဖြစ်စေရန် default preference ဖြင့် ခွင့်ပြုသည် (`LOCAL_PREF 100`)။*

??? question "Prefix de-aggregation hijacks များကို ကာကွယ်ရာတွင် RPKI ROAs ရှိ `maxLength` သည် အဘယ်ကြောင့် အလွန်အရေးပါသနည်း။"
    BGP သည် အမြဲတမ်း longest match ဖြစ်သော ပိုမိုတိကျသည့် prefix ကို ဦးစားပေးသည်။ အကယ်၍ ပစ်မှတ်ကွန်ရက်က `10.0.0.0/16` ကို ကြေညာထားပါက တိုက်ခိုက်သူသည် traffic ကို ခိုးယူရန် `10.0.1.0/24` ကို ကြေညာနိုင်သည်။ `10.0.0.0/16` အတွက် ROA ထဲတွင် `maxLength 20` ဟု သတ်မှတ်ထားခြင်းဖြင့် `/20` ထက် ပိုမိုတိကျသော (ဥပမာ `/24` ကဲ့သို့သော) မည်သည့် route ကြေညာချက်မဆိုသည် **`Invalid`** ဖြစ်သွားပြီး RPKI အသုံးပြုသော transit routers အားလုံးက drop ပစ်လိုက်မည် ဖြစ်သည်။

??? question "DDoS တိုက်ခိုက်မှုအောက်တွင် Remotely Triggered Blackhole (RTBH) နှင့် BGP Flowspec (RFC 8955) ကို နှိုင်းယှဉ်ပြပါ။"
    - **RTBH (RFC 7999 `65535:666`)**: ပစ်မှတ် `/32` IP ဆီသို့ သွားမည့် next-hop ကို ISP edge တွင် `Null0` အဖြစ် ပြောင်းလဲသတ်မှတ်သည်။ WAN bandwidth ကို ထိန်းသိမ်းရန်အတွက် ထို IP ဆီသို့ သွားမည့် **traffic ၁၀၀% လုံးကို** (တိုက်ခိုက်မှုရော ပုံမှန်ပါ) drop ပစ်လိုက်သည်။
    - **BGP Flowspec (RFC 8955)**: တိကျသော 5-tuple ACL filtering rules များကို (ဥပမာ `203.0.113.50` ဆီသို့ သွားမည့် UDP port 123 NTP amplification traffic ကို drop ရန်) transit provider hardware TCAMs များထဲသို့ တိုက်ရိုက် ထည့်သွင်းပေးနိုင်သဖြင့် တိုက်ခိုက်မှု traffic များကိုသာ သီးသန့်ဖယ်ရှားပေးပြီး ပုံမှန် host ဝန်ဆောင်မှုများကို ဆက်လက်ရှင်သန်စေသည်။

---

## IXP Peering၊ BFD နှင့် GTSM {: #ixp-peering-bfd-gtsm }

??? question "Internet peering links များပေါ်တွင် စံ BGP hold timers များအစား BFD ကို အဘယ်ကြောင့် ပိုမိုဦးစားပေးသနည်း။"
    စံ BGP hold timers များသည် (Default ၁၈၀ စက္ကန့်) link ပြတ်တောက်မှုကို သိရှိရန် ၃ မိနစ်အထိ ကြာမြင့်နိုင်သည်။ **BFD (Bidirectional Forwarding Detection)** သည် link သို့မဟုတ် optical degradation ကို တစ်စက္ကန့်အောက် (<1 second) ဖြင့် သိရှိနိုင်ရန် hardware-offloaded micro-probes များကို (ဥပမာ 300 ms) လျင်မြန်စွာ ဖလှယ်ပြီး ချက်ချင်း BGP path convergence ဖြစ်စေသည်။

??? question "GTSM (Generalized TTL Security Mechanism, RFC 3682) သည် eBGP sessions များကို မည်သို့ ကာကွယ်ပေးသနည်း။"
    GTSM သည် အပြင်သို့ ထွက်ခွာသော eBGP packet TTL ကို 255 သတ်မှတ်ပြီး အတွင်းသို့ ဝင်လာသော packets များတွင် `ttl-security hops 1` ကို သတ်မှတ်သည် (`TTL >= 254` ရှိရမည်)။ ကြားခံ routers များသည် hop တစ်ခုစီတွင် TTL ကို ၁ လျှော့ချသောကြောင့် အင်တာနက်ပေါ်ရှိ အဝေးမှ တိုက်ခိုက်သူသည် port 179 ကို ပစ်မှတ်ထား၍ TCP packets များကို CPU ထံ မရောက်မီ edge hardware ASICs များက drop ပစ်လိုက်ခြင်း မခံရဘဲ လှမ်းပို့နိုင်ခြင်း မရှိတော့ပေ။

??? question "IXP Route Server သည် အဖွဲ့ဝင်များ၏ privacy ကို မည်သို့ ထိန်းသိမ်းပြီး Next-Hop manipulation မဖြစ်အောင် မည်သို့ ကာကွယ်သနည်း။"
    IXP Route Server သည် `AS_PATH` ထဲမှ ၎င်း၏ ကိုယ်ပိုင် ASN ကို ဖယ်ရှားပေးပြီး `no-next-hop-change` ကို အသုံးပြုသည်။ ၎င်းသည် peering ပြုလုပ်သော အဖွဲ့ဝင်နှစ်ဦး (AS 100 နှင့် AS 200) အား data path သို့မဟုတ် `AS_PATH` ထဲသို့ RS ကို မထည့်သွင်းဘဲ Route Server မှတစ်ဆင့် routes ဖလှယ်ခွင့်ပေးပြီး IXP switch fabric ပေါ်တွင် တိုက်ရိုက် peer-to-peer data plane forwarding ပြုလုပ်စေနိုင်သည်။

---

## CGNAT နှင့် IPv6 ကူးပြောင်းမှု {: #cgnat-ipv6 }

??? question "RFC 6598 Shared Address Space ဆိုသည်မှာ အဘယ်နည်း၊ CGNAT အတွက် အဘယ်ကြောင့် အသုံးပြုသနည်း။"
    RFC 6598 သည် Service Provider Carrier-Grade NAT (CGNAT) အတွက် သီးသန့် `100.64.0.0/10` ကို သတ်မှတ်ပေးထားသည်။ ၎င်းသည် customer များ၏ private LANs (RFC 1918) နှင့် ISP internal core routing tables များအကြား IP address ထပ်တူကျ ပဋိပက္ခဖြစ်ခြင်းမှ ကာကွယ်ပေးသည်။

??? question "Deterministic NAT (Port-Block Allocation) သည် logging scale ပြဿနာကို မည်သို့ ဖြေရှင်းပေးသနည်း။"
    စံ NAT သည် 5-tuple translation တိုင်းကို တစ်ခုချင်းစီ log မှတ်တမ်းတင်သဖြင့် တစ်ရက်လျှင် terabytes ပေါင်းများစွာသော log data များကို ထုတ်ပေးသည်။ Deterministic NAT သည် subscriber တစ်ဦးစီအတွက် ပုံသေ ports blocks များကို သင်္ချာနည်းအရ ခွဲဝေပေးထားသဖြင့် မည်သည့် public IP + port ကိုမဆို connection တစ်ခုချင်းစီ log မှတ်စရာမလိုဘဲ ပုံသေသင်္ချာဖော်မြူလာဖြင့် ($\text{Port Start} = 1024 + \text{Subscriber Index} \times 1024$) သက်ဆိုင်ရာ subscriber ထံသို့ ပြန်လည် map လုပ်နိုင်သည်။

??? question "DNS64/NAT64 သည် IPv6-only clients များကို IPv4-only ဝန်ဆောင်မှုများဆီသို့ မည်သို့ ဆက်သွယ်ပေးသနည်း။"
    IPv6 client တစ်ခုသည် IPv4-only host တစ်ခုအတွက် AAAA record ကို တောင်းဆိုသည့်အခါ **DNS64** သည် IPv4 address ရှေ့တွင် `64:ff9b::/96` IPv6 prefix ကို ထည့်သွင်းကာ AAAA record အတုတစ်ခုကို ဖန်တီးပေးသည်။ Client က ထိုဖန်တီးထားသော address ဆီသို့ IPv6 packet ပေးပို့သည့်အခါ **NAT64** gateway က ထို packet ကို ကြားဖြတ်ဖမ်းယူပြီး IPv6 header ကို IPv4 သို့ translate လုပ်ကာ IPv4 destination ဆီသို့ ဆက်လက်ပေးပို့ပေးသည်။
