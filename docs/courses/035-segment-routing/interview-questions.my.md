# အင်တာဗျူး မေးခွန်းများ — အဆင့် ၃.၅ · Segment Routing (SR-MPLS & SRv6) {: #interview-questions-phase-35-segment-routing }

ဤကိုယ်တိုင်စစ်ဆေးနိုင်သော မေးခွန်းများသည် **Google Network Infrastructure Engineer (NIE)**၊ **FAANG WAN Systems Engineer**၊ နှင့် **Segment Routing ကျွမ်းကျင်သူ** နည်းပညာဆိုင်ရာ အင်တာဗျူး မေးခွန်းများကို အဓိက ဦးတည်ထားပါသည်။

---

## SR-MPLS နှင့် SID လုပ်ဆောင်ချက်များ {: #sr-mpls-sid-mechanics }

??? question "Segment Routing ၏ အဓိက ဗိသုကာဆိုင်ရာ အားသာချက်သည် RSVP-TE နှင့် LDP တို့ထက် မည်သို့ သာလွန်သနည်း။"
    Segment Routing သည် network core (P routers) များထံမှ state ဝန်ထုပ်ဝန်ပိုးများကို ဦးခေါင်းပိုင်း ingress router (PE) ရှိ packet header ထံသို့ လွှဲပြောင်းပေးလိုက်သည်။ Core router များတွင် **soft state လုံးဝမရှိတော့ပါ** (RSVP Refresh message များ သို့မဟုတ် signaling timer များ မလိုတော့ပါ)။ ထို့ကြောင့် signaling overhead ကို လုံးဝ ပပျောက်စေပြီး ကွန်ရက်များကို အကန့်အသတ်မရှိ စကေးချဲ့နိုင်စေသည်။

??? question "Prefix SID၊ Node SID၊ နှင့် Adjacency SID တို့အကြား ခြားနားချက်မှာ အဘယ်နည်း။"
    - **Prefix SID**: IP prefix တစ်ခုကို ကိုယ်စားပြုသော global segment ဖြစ်သည်။
    - **Node SID**: သီးခြား router တစ်ခု၏ loopback IP ကို ကိုယ်စားပြုရန် SRGB (`16000–23999`) ထဲမှ သတ်မှတ်ထားသော အထူး Prefix SID ဖြစ်သည်။ Domain တစ်ခုလုံးတွင် တစ်ကမ္ဘာလုံးအတိုင်းအတာဖြင့် တစ်မူထူးခြားသည်။
    - **Adjacency SID**: သီးခြား physical link တစ်ခုကို ကိုယ်စားပြုသော local segment ဖြစ်သည်။ Dynamic အနေဖြင့် သတ်မှတ်ပေးပြီး (`24000+`) ထုတ်ပေးသော router တစ်ခုတည်းပေါ်တွင်သာ သက်ရောက်မှုရှိသည်။

---

## Ti-LFA နှင့် Sub-50ms Fast Reroute {: #ti-lfa-sub-50ms-fast-reroute }

??? question "Classic LFA သည် ring topology များတွင် ကျရှုံးနိုင်သော်လည်း Ti-LFA သည် link/node ချို့ယွင်းမှုအတွက် အဘယ်ကြောင့် 100% အပြည့်အဝ အကာအကွယ်ပေးနိုင်သနည်း။"
    Classic LFA (RFC 5286) သည် အခြေခံ neighbor မညီမျှမှုများကိုသာ စစ်ဆေးတွက်ချက်သည်။ Ring topology များတွင် အနီးရှိ router များသည် ပျက်စီးသွားသော link ကို ဖြတ်၍ traffic ကို ပြန်လည်မောင်းနှင်မိကာ micro-loops များ ဖြစ်ပေါ်စေတတ်သည်။ **Ti-LFA (Topology-Independent LFA)** သည် တိကျသော P-Space နှင့် Q-Space node ဆုံချက်များကို တွက်ချက်ပြီး post-convergence လမ်းကြောင်းအတိုင်း သွားစေရန် explicit segment label stack များကို တွန်းပို့ (push) လုပ်ဆောင်ပေးသည်။

??? question "Ti-LFA တွက်ချက်မှုများရှိ P-Space၊ Q-Space၊ နှင့် PQ Node တို့ကို ရှင်းပြပါ။"
    - **P-Space**: ပျက်စီးသွားသော link ကို မဖြတ်သန်းဘဲ source router မှ တိုက်ရိုက်ရောက်ရှိနိုင်သော router အစုအဝေး။
    - **Q-Space**: ပျက်စီးသွားသော link ကို မဖြတ်သန်းဘဲ target destination သို့ ရောက်ရှိနိုင်သော router အစုအဝေး။
    - **PQ Node**: Traffic အား loop မဖြစ်စေဘဲ စိတ်ချစွာ ပေးပို့နိုင်သည့် ဆုံမှတ် node ($\text{P} \cap \text{Q}$) ဖြစ်သည်။

---

## SR-PCE နှင့် BGP Color Steering {: #sr-pce-bgp-color-steering }

??? question "SR-TE တွင် BGP Color Extended Community steering သည် မည်သို့ အလုပ်လုပ်သနည်း။"
    Headend router သည် **Color Extended Community** (ဥပမာ `color:100`) ပါရှိသော အတွင်းဝင် BGP route များကို စစ်ဆေးအကဲဖြတ်သည်။ အကယ်၍ `Color 100 + Endpoint IP` အတွက် ကိုက်ညီသော Segment Routing TE policy ရှိနေပါက router သည် အဆိုပါ BGP route ကို SR-TE tunnel forwarding entry ထဲသို့ အလိုအလျောက် ထည့်သွင်းပေးပြီး traffic ကို သတ်မှတ်ထားသော low-latency သို့မဟုတ် high-bandwidth label stack ထဲသို့ လမ်းကြောင်းလွှဲပို့ပေးသည်။
