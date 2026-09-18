# 🧪 Lab 05 · MPLS L2VPN (VPWS Pseudowire နှင့် VPLS) {: #lab-05-mpls-l2vpn-vpws-pseudowire-vpls }

> ✅ **စမ်းသပ်အတည်ပြုပြီး** - Arista cEOS 4.32.0F ပေါ်တွင် OrbStack fabric မှ output များကို တိုက်ရိုက်ရယူထားပါသည်။

**ကြာချိန်:** ~၅၀ မိနစ် · **Nodes အရေအတွက်:** ၄ ခု (PE Router ၂ လုံး၊ P Core Router ၁ လုံး၊ Customer L2 Switch ၂ လုံး)

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
          docker exec -it clab-mpls-l3vpn-lab-pe1 Cli
          ```

---

## L2VPN Topology နှင့် ဝန်ဆောင်မှု ပုံစံများ {: #l2vpn-topology-service-models }

```mermaid
graph LR
    subgraph SiteA["Customer Site A (L2 Domain)"]
        CE1["ce1 (Cust L2 Switch)<br/>VLAN 10"]
    end

    subgraph CoreProvider["Service Provider MPLS Backbone (AS 65000)"]
        PE1["pe1 (PE Router)<br/>2.2.2.2/32"] <===>|OSPF + LDP| P1["p1 (P Core)<br/>1.1.1.1/32"]
        P1 <===>|OSPF + LDP| PE2["pe2 (PE Router)<br/>3.3.3.3/32"]
        PE1 -.-|Targeted LDP Pseudowire (VC ID 100)| PE2
    end

    subgraph SiteB["Customer Site B (L2 Domain)"]
        CE2["ce2 (Cust L2 Switch)<br/>VLAN 10"]
    end

    CE1 <===>|Untagged / Dot1q| PE1
    PE2 <===>|Untagged / Dot1q| CE2

    classDef cust fill:#e65100,stroke:#ffb74d,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef pe fill:#1b5e20,stroke:#81c784,color:#ffffff,stroke-width:2px,font-weight:bold;
    classDef p fill:#0d47a1,stroke:#64b5f6,color:#ffffff,stroke-width:2px,font-weight:bold;

    class CE1,CE2 cust; class PE1,PE2 pe; class P1 p;
```

### L2VPN ဝန်ဆောင်မှု အမျိုးအစားများ နှိုင်းယှဉ်ချက် {: #l2vpn-service-types-comparison }

| L2VPN ဝန်ဆောင်မှု | RFC စံနှုန်း | Topology | Control Plane | Data Plane Framing |
|---|---|---|---|---|
| **VPWS (Pseudowire / EoMPLS)** | RFC 4664 / RFC 4447 | Point-to-Point (E-LINE) | Targeted LDP (tLDP) | L2 Ethernet over MPLS |
| **VPLS** | RFC 4761 (BGP) / RFC 4762 (LDP) | Point-to-Multipoint (E-LAN) | BGP / tLDP + MAC Learning | MPLS Pseudowire Mesh + Split Horizon |
| **EVPN-VPWS** | RFC 8214 | Point-to-Point (E-LINE) | BGP EVPN (AFI 25 / SAFI 70) | VXLAN သို့မဟုတ် MPLS Encapsulation |
| **EVPN-ELAN** | RFC 7432 | Point-to-Multipoint (E-LAN) | BGP EVPN (RT-2 MAC/IP, RT-3 IMET) | VXLAN သို့မဟုတ် MPLS Encapsulation |

---

## အဆင့် ၁ · Point-to-Point VPWS Pseudowire ပြင်ဆင်သတ်မှတ်ခြင်း (LDP) {: #step-1-point-to-point-vpws-pseudowire-configuration }

`pe1` ပေါ်တွင် Virtual Circuit ID `100` ဖြင့် `pe2` (`3.3.3.3`) သို့ ချိတ်ဆက်သည့် **Targeted LDP Pseudowire** သို့ interface `Ethernet2` ကို ချိတ်ဆက်သတ်မှတ်ပါ။

```eos
! Applied on pe1 (Arista cEOS)
patch panel
   patch CUST-A-PW
      connector 1 interface Ethernet2
      connector 2 pseudowire bgp vpws CUST-A pseudowire PW1
!
mpls ldp
   router-id 2.2.2.2
   transport-address interface Loopback0
   interface Ethernet1
   no shutdown
```

Arista EOS ပေါ်တွင် static / tLDP pseudowire interface ချိတ်ဆက်မှု အခြားပုံစံ:

```eos
! Interface Pseudowire cross-connect configuration
interface Ethernet2
   no switchport
   pseudowire-connection PW-CE1-CE2
      neighbor 3.3.3.3 pseudowire-id 100
```

---

## အဆင့် ၂ · L2VPN Pseudowire အခြေအနေ စစ်ဆေးခြင်း {: #step-2-verification-of-l2vpn-pseudowire-state }

Pseudowire Virtual Circuit (VC) သည် `Up` ဖြစ်နေပြီး အတွင်းပိုင်း L2 label များကို အပြန်အလှန် လဲလှယ်ထားခြင်း ရှိမရှိ စစ်ဆေးပါ။

```bash
docker exec -i clab-mpls-l3vpn-lab-pe1 Cli -p 15 <<'EOF'
enable
show mpls pseudowire
EOF
```

```
Pseudowire status: 1 total, 1 up, 0 down
Peer ID     VC ID   Type       Local Label  Remote Label  Status
3.3.3.3     100     Ethernet   100201       200302        Up
```

✅ **အောင်မြင်မှု သတ်မှတ်ချက်:** Pseudowire status တွင် တည်ဆောက်ပြီးသော VC ID 100 ဖြင့် `Up` ဟု ပြသရပါမည်။

---

## 🧠 Google Network Infra ဗဟုသုတမျှဝေမှုနှင့် L2VPN သဘောတရားများ {: #google-network-infra-knowledge-sharing }

> [!NOTE]
> ### ၁။ MPLS L2VPN Packet ဖွဲ့စည်းပုံ (PW Control Word နှင့် Control Protocol)
>
> MPLS L2VPN packet တစ်ခုတွင် အောက်ပါအတိုင်း ပါဝင်သည်:
>
> ```
> [ L2 Transport Header ] [ Outer MPLS Transport Label (LDP) ] [ Inner Pseudowire Label (tLDP/BGP) ] [ Control Word (Optional) ] [ Original Customer L2 Frame ]
> ```
>
> - **Control Word (CW)**: အတွင်းပိုင်း PW label နှင့် customer Layer 2 Ethernet payload ကြားတွင် ထည့်သွင်းထားသော 4-byte header ဖြစ်သည်။ ၎င်းသည် packet များ အစီအစဉ်လွဲချော်ခြင်းကို ကာကွယ်ပေးပြီး ECMP လမ်းကြောင်းများတစ်လျှောက် sequence numbering ကို ထိန်းသိမ်းပေးသည်။

> [!IMPORTANT]
> ### ၂။ VPLS Split-Horizon Loop ကာကွယ်မှု စည်းမျဉ်း
>
> **VPLS (Virtual Private LAN Service)** တွင် PE များသည် pseudowires အပြည့် full mesh ဖွဲ့စည်းထားကြသည်။ Provider core တစ်လျှောက် Spanning Tree Protocol မ run ဘဲ Layer 2 loop များကို ကာကွယ်ရန်:
> - **Split Horizon Rule**: PE တစ်ခုထံမှ Ingress pseudowire မှ လက်ခံရရှိသော frame တစ်ခုကို အခြား PE တစ်ခုဆီသို့ pseudowire မှတစ်ဆင့် **မည်သည့်အခါမျှ ပြန်လည် forward မလုပ်ရ (NEVER re-forward)**။ ၎င်းကို local customer ချိတ်ဆက်ထားသော interface သို့သာ forward လုပ်ခွင့်ရှိသည်!

---

## ရှင်းလင်းသိမ်းဆည်းခြင်း (Clean up) {: #clean-up }

```bash
sudo containerlab destroy -t topology.clab.yml
```
