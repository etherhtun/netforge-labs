# ၄ · Inter-AS L3VPN Options A, B, နှင့် C ဗိသုကာ နှိုင်းယှဉ်ချက် {: #4-inter-as-l3vpn-options-a-b-c }

Customer L3VPN များကို autonomous system များ သို့မဟုတ် ဝန်ဆောင်မှုပေးသူ အဖွဲ့အစည်းများစွာကြား ချိတ်ဆက်သောအခါ RFC 4364 သည် စံနှုန်းသတ်မှတ်ထားသော Inter-AS ဗိသုကာပုံစံ ၃ မျိုးကို သတ်မှတ်ထားပါသည်: **Option A**၊ **Option B**၊ နှင့် **Option C**။

---

## ၁။ Inter-AS Option A: Back-to-Back VRF Handoff {: #1-inter-as-option-a }

**Option A** တွင် Autonomous System Border Routers (ASBRs) များသည် သီးသန့် back-to-back sub-interface များ သို့မဟုတ် VLAN များဖြင့် ချိတ်ဆက်ကြသည်။ Customer VRF တစ်ခုစီအတွက် ASBR အချင်းချင်းကြားတွင် သီးခြား sub-interface နှင့် eBGP session တစ်ခုစီ လိုအပ်ပါသည်။

```mermaid
graph LR
    subgraph AS65001["AS 65001"]
        PE1["pe1 (PE)"] --- ASBR1["asbr1 (ASBR)<br/>VRF RED & VRF BLUE"]
    end

    subgraph AS65002["AS 65002"]
        ASBR2["asbr2 (ASBR)<br/>VRF RED & VRF BLUE"] --- PE2["pe2 (PE)"]
    end

    ASBR1 <===>|Sub-Intf VRF RED (eBGP)| ASBR2
    ASBR1 <===>|Sub-Intf VRF BLUE (eBGP)| ASBR2

    classDef asbr fill:#4a148c,stroke:#ba68c8,color:#ffffff,stroke-width:2px,font-weight:bold;
    class ASBR1,ASBR2 asbr;
```

- **အားသာချက်များ**: အကောင်အထည်ဖော်ရ ရိုးရှင်းသည်၊ နယ်စပ် (boundary) တွင် VRF တစ်ခုစီအလိုက် QoS နှင့် လုံခြုံရေးမူဝါဒများကို တိကျစွာ ထိန်းချုပ်နိုင်သည်။
- **အားနည်းချက်များ**: စကေးချဲ့နိုင်စွမ်း (scalability) အကန့်အသတ်ရှိသည် (Customer VRF $N$ ခုအတွက် sub-interface $N$ ခုနှင့် eBGP session $N$ ခု လိုအပ်သည်)။

---

## ၂။ Inter-AS Option B: ASBR MP-eBGP VPNv4 Exchange {: #2-inter-as-option-b }

**Option B** တွင် ASBR များသည် တစ်ခုတည်းသော **MP-eBGP VPNv4** session ကို ထိန်းသိမ်းထားရှိသည်။ ASBR များပေါ်တွင် customer VRF လုံးဝမလိုအပ်ဘဲ global BGP table ထဲတွင် VPNv4 route အားလုံးကို သိမ်းဆည်းထားသည်။ Route များကို ပြန်လည်ကြေညာသည့်အခါ ASBR များသည် အတွင်းပိုင်း VPN label ကို swap လုပ်ပေးသည်။

```mermaid
graph LR
    subgraph AS65001["AS 65001"]
        PE1["pe1 (PE)"] -.-|MP-iBGP VPNv4| ASBR1["asbr1 (ASBR)"]
    end

    subgraph AS65002["AS 65002"]
        ASBR2["asbr2 (ASBR)"] -.-|MP-iBGP VPNv4| PE2["pe2 (PE)"]
    end

    ASBR1 <===>|Inter-AS MP-eBGP VPNv4<br/>(ASBR Label Swapping)| ASBR2

    classDef asbr fill:#4a148c,stroke:#ba68c8,color:#ffffff,stroke-width:2px,font-weight:bold;
    class ASBR1,ASBR2 asbr;
```

- **အားသာချက်များ**: ASBR များပေါ်တွင် customer VRF များ သတ်မှတ်ရန် မလိုပါ၊ စကေးချဲ့နိုင်စွမ်း မြင့်မားသည်။
- **အားနည်းချက်များ**: ASBR များသည် VPNv4 route အားလုံးကို memory ထဲတွင် သိမ်းဆည်းထားရသည် ($O(V)$ route table scaling overhead)။

---

## ၃။ Inter-AS Option C: Hyperscale BGP-LU (RFC 3107) + Multi-Hop MP-eBGP {: #3-inter-as-option-c }

**Option C** တွင် ASBR များသည် PE loopback address (`/32`) များအတွက်သာ label ဖလှယ်ရန် **BGP Labeled Unicast (BGP-LU RFC 3107 / 8277)** ကို အသုံးပြုကြသည်။ PE များသည် အဝေးရှိ PE များနှင့် တိုက်ရိုက် **multi-hop MP-eBGP** session များ ဖွဲ့စည်းကြသည်။

```mermaid
graph LR
    subgraph AS65001["AS 65001"]
        PE1["pe1 (PE)<br/>2.2.2.2/32"] --- ASBR1["asbr1 (ASBR)"]
    end

    subgraph AS65002["AS 65002"]
        ASBR2["asbr2 (ASBR)"] --- PE2["pe2 (PE)<br/>3.3.3.3/32"]
    end

    ASBR1 <===>|BGP-LU (RFC 3107)<br/>2.2.2.2 နှင့် 3.3.3.3 + Transport Labels ဖလှယ်ခြင်း| ASBR2
    PE1 -.-|Multi-Hop MP-eBGP VPNv4 (တိုက်ရိုက် PE-to-PE)| PE2

    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef asbr fill:#4a148c,stroke:#ba68c8,color:#ffffff,stroke-width:2px,font-weight:bold;

    class PE1,PE2 pe; class ASBR1,ASBR2 asbr;
```

- **အားသာချက်များ**: **အလွန်ကြီးမားသော စကေး (Hyperscale)** ကို ထောက်ပံ့နိုင်သည်။ ASBR များသည် customer VRF များနှင့် VPNv4 route များကို သိမ်းဆည်းရန် မလိုပါ (PE loopback များကိုသာ သိမ်းဆည်းသည်)။
- **အားနည်းချက်များ**: ရှုပ်ထွေးသော BGP-LU routing နှင့် အစအဆုံး label တပ်ဆင်ထားသည့် path များကို စနစ်တကျ ချိန်ညှိမှု လိုအပ်သည်။

---

## နှိုင်းယှဉ်ချက် အကျဉ်းချုပ် ဇယား {: #summary-comparison-matrix }

| Option | ချိတ်ဆက်မှု ပုံစံ | ASBR VRF လိုအပ်ချက် | ASBR Route Memory အသုံးပြုမှု | Data Plane Label Stack |
|---|---|---|---|---|
| **Option A** | Per-VRF Sub-Interfaces | လိုအပ်သည် ($N$ VRFs) | မြင့်မားသည် | 1 Label (Per-VRF Transport) |
| **Option B** | MP-eBGP VPNv4 | VRF မလိုပါ | အသင့်အတင့် (VPNv4 route အားလုံး သိမ်းဆည်းသည်) | 2 Labels (Transport + Swapped VPN Label) |
| **Option C** | BGP-LU + Multi-Hop MP-eBGP | VRF မလိုပါ | **အလွန်နည်းပါးသည်** (PE Loopbacks သာ) | **3 Labels** (Transport + BGP-LU + VPN Label) |
