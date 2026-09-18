# သင်တန်းများနှင့် လက်တွေ့ Labs (Courses)

Routing အခြေခံ foundations မှသည် လုပ်ငန်းခွင် network လည်ပတ်မှုအထိ Phase ၉ ခု ပါဝင်ပါသည်။ တစ်ခုချင်းစီသည် သီးခြားလေ့လာနိုင်သော်လည်း ရှေ့အဆင့်ဆင့်ကို အခြေပြု၍ စနစ်တကျ စီစဉ်ပေးထားပါသည်။

အမှန်တကယ် စမ်းသပ် run ပြီးမှသာ အောင်မြင်သည်ဟု သတ်မှတ်ပါသည်။ အဆင့်တစ်ခုချင်းစီ၏ တိုးတက်မှုကို [Roadmap လမ်းပြမြေပုံ](../roadmap.md) တွင် ကြည့်ရှုနိုင်ပါသည်။

---

## ဤနေရာမှ စတင်ပါ

<div class="grid cards" markdown>

-   **Foundations · Linux & Networking** &nbsp; <span class="nf-badge ok">မဖြစ်မနေ လိုအပ်ချက်</span>

    ---

    Shell scripting၊ စက်ပစ္စည်း output များကို parse လုပ်ခြင်း၊ SSH keys နှင့် jump hosts၊ systemd နှင့် logs၊ နှင့် config စီမံခန့်ခွဲမှုအတွက် git။ ကွန်ရက်အင်ဂျင်နီယာတစ်ဦး လက်တွေ့ အသုံးချရမည့် Linux နည်းပညာများ။

    [စတင်ဖတ်ရှုရန် →](linux-foundations/index.md)

</div>

## အခြေခံအုတ်မြစ်များ (Foundations)

<div class="grid cards" markdown>

-   **Phase 0 · IGP Fundamentals** &nbsp; <span class="nf-badge ok">သဘောတရားဖတ်ရှုရန်</span>

    ---

    Link-state routing၊ OSPF၊ IS-IS၊ dual-stack IPv6။ နောက်ပိုင်း phases များအားလုံးအတွက် မရှိမဖြစ် underlay အခြေခံ။ Lab မပါပါ — သဘောတရားကို ဖတ်ရှုပြီး နောက်အဆင့်သို့ ဆက်သွားပါ။

    [စတင်ဖတ်ရှုရန် →](00-igp-fundamentals/index.md)

-   **Phase 1 · BGP Fundamentals & Policies** &nbsp; <span class="nf-badge ok">Labs ၄ ခု အတည်ပြုပြီး</span>

    ---

    eBGP နှင့် iBGP၊ route reflectors၊ path selection၊ နှင့် မည်သည့် route က အနိုင်ရမည်ကို ဆုံးဖြတ်ပေးသော policy tooling စနစ်များ။

    [ခြုံငုံသုံးသပ်ချက် →](01-bgp/index.md) · [Lab 01 →](01-bgp/lab-01-ebgp-ibgp.md) · [သဘောတရားများ →](01-bgp/concepts/index.md)

-   **Phase 2 · BGP-DIA & Internet Edge** &nbsp; <span class="nf-badge ok">Labs ၄ ခု အတည်ပြုပြီး</span>

    ---

    Providers အများအပြားနှင့် multi-homing ချိတ်ဆက်ခြင်း၊ RPKI၊ IXP peering၊ နှင့် edge ရှိ NAT / CGNAT စနစ်များ။

    [ခြုံငုံသုံးသပ်ချက် →](02-bgp-dia/index.md) · [Lab 01 →](02-bgp-dia/lab-01-dia-multihoming.md) · [အင်တာဗျူး မေးခွန်းများ →](02-bgp-dia/interview-questions.md)

</div>

## ဆက်သွယ်ရေး အခြေခံအဆောက်အအုံ (Service Provider)

<div class="grid cards" markdown>

-   **Phase 3 · MPLS & L3VPN** &nbsp; <span class="nf-badge ok">Labs ၄ ခု အတည်ပြုပြီး</span>

    ---

    Labels များ လဲလှယ်၍ traffic ပို့ဆောင်ခြင်း။ LDP၊ RSVP-TE၊ နှင့် L3VPN options A၊ B နှင့် C ဗိသုကာများ။

    [ခြုံငုံသုံးသပ်ချက် →](03-mpls-l3vpn/index.md) · [Lab 01 →](03-mpls-l3vpn/lab-01-mpls-ldp.md) · [အင်တာဗျူး မေးခွန်းများ →](03-mpls-l3vpn/interview-questions.md)

-   **Phase 3.5 · Segment Routing** &nbsp; <span class="nf-badge ok">Labs ၃ ခု အတည်ပြုပြီး</span>

    ---

    SR-MPLS၊ SR-PCE၊ Ti-LFA နှင့် SRv6 အခြေခံများ။ Core တွင် state မဆောက်ဘဲ Hyperscalers များ traffic လမ်းကြောင်းလွှဲပုံနှင့် SDN controllers များ IGPs နှင့် ချိတ်ဆက်ပုံ။

    [ခြုံငုံသုံးသပ်ချက် →](035-segment-routing/index.md) · [Lab 01 →](035-segment-routing/lab-01-sr-mpls-sids.md) · [အင်တာဗျူး မေးခွန်းများ →](035-segment-routing/interview-questions.md)

</div>

## Data Center

<div class="grid cards" markdown>

-   **Phase 4 · EVPN Services** &nbsp; <span class="nf-badge ok">Labs ၄ ခု အတည်ပြုပြီး</span>

    ---

    VXLAN-EVPN fabrics၊ EVPN-ELAN နှင့် EVPN-VPWS၊ နှင့် DCI ဖြင့် data centers အချင်းချင်းကြား EVPN ချိတ်ဆက်ခြင်း။

    [ခြုံငုံသုံးသပ်ချက် →](04-evpn/index.md) · [Lab 01 →](04-evpn/lab-01-pure-l2vni.md) · [သဘောတရားများ →](04-evpn/concepts/index.md)

</div>

## လုပ်ငန်းခွင် လည်ပတ်မှု (Operations)

<div class="grid cards" markdown>

-   **Phase 5 · NetDevOps (Network Automation)** &nbsp; <span class="nf-badge ok">Labs ၅ ခု အတည်ပြုပြီး</span>

    ---

    Jinja2/YAML၊ PyATS assertions၊ Batfish static analysis၊ နှင့် GitHub Actions CI/CD pipelines ဖြင့် ကွန်ရက်ကို code ကဲ့သို့ အလိုအလျောက် စီမံခန့်ခွဲခြင်း။

-   **Phase 6 · Hybrid Cloud & WAN Edge** &nbsp; <span class="nf-badge ok">Labs ၄ ခု အတည်ပြုပြီး</span>

    ---

    Dual-ISP eBGP multihoming၊ AS-PATH prepending၊ BFD မီလီစက္ကန့်အတွင်း လမ်းကြောင်းလွှဲခြင်းနှင့် RPKI ROV။

-   **Phase 7 · Telemetry & Observability** &nbsp; <span class="nf-badge ok">Labs ၅ ခု အတည်ပြုပြီး</span>

    ---

    ရှေးဟောင်း SNMP အစား gNMI နှင့် OpenConfig streaming telemetry အသုံးပြုခြင်း။ Prometheus၊ Grafana နှင့် အလိုအလျောက် alerting စနစ်များ။

</div>

---

!!! tip "ဘယ်က စရမလဲ မသေချာဘူးလား။"
    **Routing အသစ် လေ့လာသူများ** — Phase 0၊ ပြီးနောက် 1 နှင့် 2။ **Data Center ဦးစားပေးသူများ** — Phase 1၊ ထို့နောက် လက်ရှိအသင့်ရှိသော Phase 4 သို့ တိုက်ရိုက်ကူးပါ။ **Service Provider ဦးစားပေးသူများ** — Phase 1၊ ထို့နောက် 3 နှင့် 3.5။ **Protocols သိပြီးသူများ** — လက်တွေ့လုပ်ငန်းခွင် အဓိကဖြစ်သော Phases 5 နှင့် 7 မှ စတင်ပါ။

ထို့အပြင် ဖတ်ရှုလေ့လာနိုင်သော [Juniper VXLAN-EVPN Archive](../archive/juniper-vxlan-evpn/index.md) သင်ရိုးလည်း ရှိပါသည်။
