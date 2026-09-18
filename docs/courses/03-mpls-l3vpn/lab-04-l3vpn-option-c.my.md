# 🧪 Lab 04 · Inter-AS L3VPN Option C (BGP-LU RFC 3107 နှင့် Multi-Hop MP-eBGP) {: #lab-04-inter-as-l3vpn-option-c }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၆၀ မိနစ် · **Nodes အရေအတွက်:** ၆ ခု (AS 65001 နှင့် AS 65002 အကြား PE Router ၂ လုံး၊ ASBR Router ၂ လုံး၊ P Core Router ၂ လုံး)

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

## Hyperscale ဗိသုကာနှင့် BGP-LU Flow {: #hyperscale-architecture-bgp-lu-flow }

```mermaid
graph LR
    subgraph AS65001["Service Provider AS 65001"]
        PE1["pe1 (PE Router)<br/>Loopback: 2.2.2.2"] --- ASBR1["asbr1 (ASBR)"]
    end

    subgraph AS65002["Service Provider AS 65002"]
        ASBR2["asbr2 (ASBR)"] --- PE2["pe2 (PE Router)<br/>Loopback: 3.3.3.3"]
    end

    ASBR1 <===>|BGP Labeled Unicast (RFC 3107)<br/>2.2.2.2/32 နှင့် 3.3.3.3/32 + Labels ဖလှယ်ခြင်း| ASBR2
    PE1 -.-|Multi-hop MP-eBGP VPNv4 (တိုက်ရိုက် PE-to-PE)| PE2

    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef asbr fill:#4a148c,stroke:#ba68c8,color:#ffffff,stroke-width:2px,font-weight:bold;

    class PE1,PE2 pe; class ASBR1,ASBR2 asbr;
```

---

## အဆင့် ၁ · BGP Labeled Unicast (BGP-LU RFC 3107 / 8277) {: #step-1-bgp-labeled-unicast }

ASBR များ (`asbr1` နှင့် `asbr2`) ပေါ်တွင် inter-AS boundary ကို ဖြတ်သန်း၍ PE Loopback များ (`2.2.2.2/32` နှင့် `3.3.3.3/32`) အတွက် MPLS label များ ဖြန့်ဝေပေးရန် `ipv4 labeled-unicast` address-family ၌ BGP Labeled Unicast ကို ဖွင့်ပါ။

```eos
! Applied on asbr1 (AS 65001)
router bgp 65001
   neighbor 10.0.12.2 remote-as 65002
   neighbor 10.0.12.2 description "BGP-LU-InterAS-asbr2"
   !
   address-family ipv4
      neighbor 10.0.12.2 activate
   address-family ipv4 labeled-unicast
      neighbor 10.0.12.2 activate
```

**စစ်ဆေးခြင်း:**

```bash
docker exec -i clab-mpls-l3vpn-lab-asbr1 Cli -p 15 <<'EOF'
enable
show ip bgp labeled-unicast
EOF
```

```
Network            Next Hop         In Label   Out Label
*> 3.3.3.3/32      10.0.12.2        100105     200401
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** `3.3.3.3/32` သည် မှန်ကန်သော `In Label` နှင့် `Out Label` တို့ဖြင့် `show ip bgp labeled-unicast` တွင် ပေါ်လာရပါမည်။

---

## အဆင့် ၂ · PE များကြား Multi-Hop MP-eBGP VPNv4 Session ချိတ်ဆက်ခြင်း {: #step-2-multi-hop-mp-ebgp-vpnv4-session-between-pes }

BGP-LU မှ `pe1` (`2.2.2.2`) နှင့် `pe2` (`3.3.3.3`) ကြားတွင် အစအဆုံး label တပ်ဆင်ထားသည့် လမ်းကြောင်းကို ပံ့ပိုးပေးထားပြီးဖြစ်၍ PE နှစ်ခုကြားတွင် တိုက်ရိုက် **multi-hop MP-eBGP** session ကို ချိန်ညှိပါ။

```eos
! Applied on pe1 (AS 65001) targeting pe2 (AS 65002)
router bgp 65001
   neighbor 3.3.3.3 remote-as 65002
   neighbor 3.3.3.3 ebgp-multihop 10
   neighbor 3.3.3.3 update-source Loopback0
   !
   address-family vpn-ipv4
      neighbor 3.3.3.3 activate
```

**Data Plane Packet Stack (Three-Label Stack ၃ ထပ်ပုံစံ):**

```
[ Outer AS Transport Label (LDP) ] [ Middle Inter-AS Label (BGP-LU) ] [ Inner VPN Service Label (VPNv4) ] [ Customer Packet ]
```

---

## 🧠 Google Network Infra ဗဟုသုတမျှဝေမှုနှင့် Hyperscale အင်ဂျင်နီယာပညာရပ် {: #google-network-infra-knowledge-sharing }

> [!NOTE]
> ### ၁။ Hyperscalers (Google / AWS / Meta) များသည် Option C ကို အဘယ်ကြောင့် ရွေးချယ်သနည်း
>
> 1. **ASBR များပေါ်တွင် Customer VPN State လုံးဝမရှိခြင်း**: ASBR များသည် customer VRF များနှင့် customer VPNv4 route များကို သယ်ဆောင်ရန် မလိုအပ်ပါ။ PE loopback များအတွက် BGP-LU route များကိုသာ သယ်ဆောင်သည် (VPN route သန်းပေါင်းများစွာ အစား PE အရေအတွက် ~10,000 ခန့်သာ)။
> 2. **အစအဆုံး Encapsulation နှင့် စွမ်းဆောင်ရည်မြင့်မားခြင်း**: Customer traffic ကို `pe1` တွင် encapsulate လုပ်ပြီး `pe2` တွင် decapsulate ပြုလုပ်သည်။ ကြားခံ ASBR များသည် သမားရိုးကျ label-switching ပြုလုပ်ပေးသော router (P routers) များအဖြစ်သာ သက်တောင့်သက်သာ လုပ်ဆောင်သည်။
> 3. **Segment Routing (SR-MPLS / SRv6) နှင့် ချောမွေ့စွာ ပေါင်းစပ်နိုင်ခြင်း**: Option C BGP-LU သည် Segment Routing Egress Peer Engineering (SR-EPE) နှင့် SDN controller များနှင့် အလွန်အမင်း ကိုက်ညီမှုရှိပါသည်။

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
