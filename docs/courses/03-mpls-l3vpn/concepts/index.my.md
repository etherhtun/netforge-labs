# အဆင့် ၃ သဘောတရားများ · MPLS နှင့် L3VPN အတွင်းကျကျလေ့လာခြင်း {: #phase-3-concepts-mpls-l3vpn-deep-dive }

> 📖 **သီအိုရီနှင့် ဗိသုကာလက်တွေ့လေ့လာမှု။** လက်တွေ့ lab များ မစတင်မီ သို့မဟုတ် ပြီးဆုံးပြီးနောက် protocol လုပ်ဆောင်ချက်များ၊ packet header များနှင့် hardware forwarding table များ၏ အတွင်းပိုင်းအလုပ်လုပ်ပုံကို နားလည်သဘောပေါက်စေရန်။

---

## သဘောတရား သင်ခန်းစာများ {: #concept-modules }

<div class="grid cards" markdown>

-   **[၁ · MPLS ဗိသုကာနှင့် Header အလုပ်လုပ်ပုံ](01-mpls-architecture.my.md)**

    ---

    32-bit MPLS Shim Header ခွဲခြမ်းစိတ်ဖြာချက် (Label, TC/Exp, Bottom-of-Stack S, TTL), Push/Swap/Pop hardware လုပ်ဆောင်ချက်များ, LIB နှင့် LFIB forwarding table များ နှိုင်းယှဉ်ချက်။

-   **[၂ · LDP နှင့် Label ပေးပို့ဖြန့်ဝေခြင်း](02-ldp-signaling.my.md)**

    ---

    LDP UDP 646 hello discovery, TCP 646 session တည်ဆောက်ခြင်း, Downstream Unsolicited (DU) နှင့် Downstream-on-Demand (DoD), Independent နှင့် Ordered control modes များ။

-   **[၃ · L3VPN Control နှင့် Data Plane (RFC 4364)](03-l3vpn-architecture.my.md)**

    ---

    64-bit Route Distinguishers (RD), BGP Extended Community Route Targets (RT), MP-BGP VPNv4 (AFI 1 / SAFI 128), Two-Label Packet Walk, Penultimate Hop Popping (PHP RFC 3032)။

-   **[၄ · Inter-AS Options A, B, နှင့် C](04-inter-as-options.my.md)**

    ---

    Option A (back-to-back VRFs), Option B (ASBR VPNv4 label swap), Option C (BGP Labeled Unicast RFC 3107/8277 + Multi-hop MP-eBGP) နှိုင်းယှဉ်ချက်နှင့် အသုံးချမှုများ။

-   **[၅ · L2VPN နှင့် Pseudowire ဗိသုကာ](05-l2vpn-pseudowire.my.md)**

    ---

    VPWS Point-to-Point Pseudowires (EoMPLS RFC 4664), Control Word (CW), VPLS Split-Horizon loop ကာကွယ်မှု စည်းမျဉ်းများ, EVPN-VPWS / EVPN-ELAN ဆီသို့ ဆင့်ကဲပြောင်းလဲမှု။

</div>
