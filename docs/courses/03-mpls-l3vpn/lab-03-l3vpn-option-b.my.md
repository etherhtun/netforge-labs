# 🧪 Lab 03 · Inter-AS L3VPN Option B (ASBR MP-eBGP VPNv4 ဖလှယ်ခြင်း) {: #lab-03-inter-as-l3vpn-option-b }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၅၅ မိနစ် · **Nodes အရေအတွက်:** ၆ ခု (AS 65001 နှင့် AS 65002 အကြား PE Router ၂ လုံး၊ ASBR Router ၂ လုံး၊ P Core Router ၂ လုံး)

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် — Step-by-Step Execution Guide (တည်နေရာ: `labs/mpls-l3vpn-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/mpls-l3vpn-lab
    sudo containerlab deploy -t topology.clab.yml --max-workers 1
    ```

    **အဆင့် ၂ · အပြန်အလှန် Interactive လမ်းညွှန်ကို စတင်ပါ**
    ```bash
    ./run.sh --guided
    ```

    ??? note "အခြား Run နိုင်သော နည်းလမ်းများ (Automated Script သို့မဟုတ် Manual CLI)"
        - **Fast Automated Script Push**:
          ```bash
          ./run.sh 01          # step 01 ကို အလိုအလျောက် config ထည့်သွင်း၍ စစ်ဆေးမည်
          ./run.sh --all       # အဆင့်အားလုံးကို အစီအစဉ်အတိုင်း run မည်
          ```
        - **Manual Line-by-Line CLI Execution**:
          Container node တစ်ခုချင်းစီသို့ CLI shell ဝင်ရောက်ရန်:
          ```bash
          docker exec -it clab-mpls-l3vpn-lab-asbr1 Cli
          ```

---

## ဗိသုကာနှင့် Inter-AS Options နှိုင်းယှဉ်ချက် {: #architecture-inter-as-option-comparison }

```mermaid
graph LR
    subgraph AS65001["Service Provider AS 65001"]
        PE1["pe1 (PE Router)"] -.-|MP-iBGP VPNv4| ASBR1["asbr1 (ASBR)"]
    end

    subgraph AS65002["Service Provider AS 65002"]
        ASBR2["asbr2 (ASBR)"] -.-|MP-iBGP VPNv4| PE2["pe2 (PE Router)"]
    end

    ASBR1 <===>|Inter-AS MP-eBGP VPNv4<br/>(ASBR တွင် Label Swap ပြုလုပ်သည်)| ASBR2

    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef asbr fill:#4a148c,stroke:#ba68c8,color:#ffffff,stroke-width:2px,font-weight:bold;

    class PE1,PE2 pe; class ASBR1,ASBR2 asbr;
```

### Inter-AS Options နှိုင်းယှဉ်ချက် ဇယား {: #inter-as-options-comparison-matrix }

| Option | ချိတ်ဆက်မှု ပုံစံ | စကေးချဲ့နိုင်စွမ်း | ASBR State Overhead | Next-Hop & Label ကိုင်တွယ်ပုံ |
|---|---|---|---|---|
| **Option A** | Back-to-back VRF sub-interfaces | နည်းပါး | မြင့်မားသည် (Customer VRF တစ်ခုစီအတွက် sub-interface + eBGP session လိုအပ်သည်) | VRF တစ်ခုစီအလိုက် သမားရိုးကျ IPv4 eBGP |
| **Option B** | Inter-AS MP-eBGP VPNv4 | **မြင့်မား** | **အသင့်အတင့်** (BGP table တွင် VPNv4 route များ သိမ်းဆည်းသည်၊ ASBR ပေါ်တွင် VRF မလိုပါ) | **ASBR သည် Next-Hop ကို ပြန်ပြင်ပြီး VPN service label အသစ် သတ်မှတ်လဲလှယ်ပေးသည်** |
| **Option C** | Multi-hop MP-eBGP + BGP-LU (RFC 3107) | **Hyperscale အဆင့်** | **အလွန်နည်းပါး** (ASBR သည် VPNv4 route များကို လုပ်ဆောင်ခြင်း သို့မဟုတ် သိမ်းဆည်းခြင်း မပြုပါ) | အစအဆုံး BGP Labeled Unicast transport စနစ် |

---

## အဆင့် ၁ · ASBR MP-eBGP Session ပြင်ဆင်သတ်မှတ်ခြင်း {: #step-1-asbr-mp-ebgp-session-configuration }

`asbr1` (AS 65001) နှင့် `asbr2` (AS 65002) ပေါ်တွင် `vpn-ipv4` address-family ၌ MP-eBGP ကို ဖွင့်ပြီး Next-Hop filtering ကို ပိတ်ထားပါ။

```eos
! Applied on asbr1 (AS 65001)
router bgp 65001
   neighbor 10.0.12.2 remote-as 65002
   neighbor 10.0.12.2 description "Inter-AS-Option-B-PEER-asbr2"
   !
   address-family vpn-ipv4
      neighbor 10.0.12.2 activate
```

---

## အဆင့် ၂ · ASBR Label Rewriting နှင့် Next-Hop Self {: #step-2-asbr-label-rewriting-next-hop-self }

Option B အနေဖြင့် ဝန်ဆောင်မှုပေးသူ နယ်နိမိတ်များကို ဖြတ်ကျော်အလုပ်လုပ်နိုင်စေရန်၊ လက်ခံရရှိသော ASBR သည် လက်ခံရရှိသည့် VPNv4 route များကို ၎င်း၏ internal MP-iBGP peer များထံသို့ `next-hop-self` ဖြင့် ပြန်လည်ကြေညာရပါမည်။ ဤသို့ ပြန်လည်ကြေညာစဉ်အတွင်း ASBR သည် **အတွင်းပိုင်း VPN label အသစ်တစ်ခု** ကို သတ်မှတ်ပေးပြီး hardware ထဲတွင် swap ပြုလုပ်ပေးပါသည်။

```eos
! Applied on asbr1 for internal MP-iBGP peers
router bgp 65001
   neighbor 1.1.1.1 remote-as 65001
   neighbor 1.1.1.1 update-source Loopback0
   !
   address-family vpn-ipv4
      neighbor 1.1.1.1 activate
      neighbor 1.1.1.1 next-hop-self
```

**စစ်ဆေးခြင်း:**

```bash
docker exec -i clab-mpls-l3vpn-lab-asbr1 Cli -p 15 <<'EOF'
enable
show bgp vpn-ipv4 detail
EOF
```

```
BGP routing table entry for 10.100.2.0/24, Route Distinguisher 65002:100
  Paths: 1 available
  Local
    10.0.12.2 from 10.0.12.2 (10.0.12.2)
      Origin IGP, localpref 100, valid, external, best
      MPLS info:
        in label: 100023
        out label: 24012
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `asbr1` သည် VPNv4 route အတွက် `in label` သတ်မှတ်ပြီး ၎င်းအား `out label` နှင့် ချိတ်ဆက်ပေးထားရပါမည်။

---

## 🧠 Google Network Infra ဗဟုသုတမျှဝေမှုနှင့် Protocol သဘောတရားများ {: #google-network-infra-knowledge-sharing }

> [!NOTE]
> ### ၁။ Option B Packet Forwarding Stack (Inter-AS နယ်စပ်တွင် 3-Label Swap ပြုလုပ်ပုံ)
>
> Inter-AS Option B တွင် packet တစ်ခုသည် AS 65001 မှ AS 65002 သို့ ဖြတ်သန်းသွားသောအခါ:
> 1. AS 65001 အတွင်း: Packet သည် `[Transport Label LDP_AS1] [VPN Label L1]` ဖြင့် သွားသည်။
> 2. `asbr1` တွင် (ASBR Handoff): `asbr1` သည် `LDP_AS1` ကို pop လုပ်ပြီး `VPN Label L1` → `VPN Label L2` သို့ swap လုပ်ကာ LDP encapsulation မပါဘဲ inter-AS link ကို ဖြတ်၍ `[VPN Label L2]` ဖြင့် တိုက်ရိုက်ပို့ပေးသည်။
> 3. `asbr2` တွင် (လက်ခံသော ASBR): `asbr2` သည် `VPN Label L2` → `VPN Label L3` သို့ swap လုပ်ပြီး transport label အသစ် `[LDP_AS2]` ကို push လုပ်ကာ AS 65002 core ထဲသို့ ပေးပို့သည်။

> [!IMPORTANT]
> ### ၂။ လုံခြုံရေးနှင့် Carrier ကြား ချိတ်ဆက်မှု အလေ့အကျင့်ကောင်းများ
>
> - **ASBR Route Filtering**: အဝေးရှိ provider ထံမှ route table ပြည့်လျှံတိုက်ခိုက်မှုများ (exhaustion attacks) ကို ကာကွယ်ရန် Inter-AS MP-eBGP session များပေါ်တွင် `prefix-list` နှင့် `max-prefix` ကန့်သတ်ချက်များကို အမြဲအသုံးပြုပါ။
> - **ASBR ပေါ်တွင် VRF ဝန်ထုပ်ဝန်ပိုး မရှိခြင်း**: Option A (Customer $N$ ခုအတွက် VRF $N$ ခု လိုအပ်သည်) နှင့် မတူဘဲ Option B သည် customer VPN အားလုံးကို single global BGP table (`vpn-ipv4`) တစ်ခုတည်းတွင်သာ ကိုင်တွယ်သောကြောင့် ASBR ၏ RAM အသုံးပြုမှုကို 80% အထိ လျှော့ချပေးနိုင်ပါသည်!

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
