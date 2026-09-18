# ၆ · EVPN VXLAN Packet စီးဆင်းမှုနှင့် Forwarding နည်းစနစ်များ {: #6-evpn-vxlan-packet-walk-forwarding-mechanics }

Packet များသည် VXLAN-EVPN fabric တစ်ခုတစ်လျှောက် ဖြတ်သန်းသွားရာတွင် မည်သို့ encapsulate လုပ်သည်၊ မည်သို့ route လုပ်သည်၊ မည်သို့ decapsulate လုပ်သည်ကို နားလည်ခြင်းသည် **Datacenter System Design အင်တာဗျူးများတွင် အရေးအကြီးဆုံးသော ခေါင်းစဉ်တစ်ခု ဖြစ်ပါသည်**။

---

## ၁။ Intra-Subnet L2 Bridging Packet စီးဆင်းပုံ (တူညီသော VNI 10100) {: #1-intra-subnet-l2-bridging-packet-walk }

```mermaid
sequenceDiagram
    autonumber
    participant H1 as host1 (10.10.10.10, MAC H1)
    participant L1 as leaf1 (Ingress VTEP 10.255.1.11)
    participant Spine as spine1 (IP Underlay)
    participant L2 as leaf2 (Egress VTEP 10.255.1.12)
    participant H2 as host2 (10.10.10.20, MAC H2)

    H1->>L1: Native L2 Ethernet Frame (Src: MAC_H1, Dst: MAC_H2)
    Note over L1: 1. L2 VNI 10100 table ထဲတွင် MAC_H2 ကို ရှာဖွေသည်<br/>2. Remote VTEP IP: 10.255.1.12 ကို တွေ့ရှိသည်<br/>3. VXLAN VNI 10100 တွင် Encapsulate ပြုလုပ်သည်
    L1->>Spine: VXLAN Packet [Outer IP: 10.255.1.11 -> 10.255.1.12] [UDP 4789] [VNI 10100] [Inner Frame]
    Note over Spine: Underlay IP ECMP Routing ကို လုပ်ဆောင်သည် (Outer IP ရှာဖွေမှု)
    Spine->>L2: VXLAN Packet [Outer IP: 10.255.1.11 -> 10.255.1.12] [VNI 10100]
    Note over L2: 1. VXLAN Header (VNI 10100) ကို Decapsulate ပြုလုပ်သည်<br/>2. Local VLAN 10 ထဲတွင် Dst MAC_H2 ကို ရှာဖွေသည်<br/>3. Access Port Et3 မှတစ်ဆင့် Frame ကို ပေးပို့သည်
    L2->>H2: Native L2 Ethernet Frame (Src: MAC_H1, Dst: MAC_H2)
```

---

## ၂။ Inter-Subnet Symmetric IRB Packet စီးဆင်းပုံ (VNI 10100 → L3VNI 50001 → VNI 10200) {: #2-inter-subnet-symmetric-irb-packet-walk }

**Symmetric Integrated Routing and Bridging (IRB)** တွင် routing သည် **ingress leaf ရော egress leaf ပါ နှစ်ဖက်စလုံးတွင် ဖြစ်ပွားပါသည်**:

```mermaid
sequenceDiagram
    autonumber
    participant H1 as host1 (10.10.10.10, VLAN 10)
    participant L1 as leaf1 (Ingress VTEP)
    participant L2 as leaf2 (Egress VTEP)
    participant H3 as host3 (10.10.20.30, VLAN 20)

    H1->>L1: Frame Dst MAC: Anycast Gateway MAC (00:1c:73:00:00:01)
    Note over L1: 1. Ingress Routing: Subnet 10.10.10.0/24 မှ 10.10.20.0/24 သို့ Route လုပ်သည်<br/>2. Src MAC ကို Leaf1 Router MAC ဖြင့် အစားထိုးပြီး Dst MAC ကို Leaf2 Router MAC ဖြင့် အစားထိုးသည်<br/>3. L3 VRF VNI 50001 အတွင်း Encapsulate ပြုလုပ်သည်
    L1->>L2: VXLAN Packet [Outer Dst IP: 10.255.1.12] [L3 VNI 50001] [Router MACs] [IP Payload]
    Note over L2: 1. L3 VNI 50001 ပေါ်တွင် လက်ခံရရှိသည်<br/>2. Egress Routing: VRF TENANT-A / VLAN 20 ထဲသို့ Route လုပ်သည်<br/>3. EVPN Type 2 table မှတစ်ဆင့် Dst Host3 MAC ကို ဖြေရှင်းဖော်ထုတ်သည်
    L2->>H3: Native Frame (Src MAC: Anycast Gateway MAC, Dst MAC: MAC_H3)
```

### Symmetric IRB သည် အဘယ်ကြောင့် အကောင်းဆုံး စကေးချဲ့နိုင်သနည်း {: #why-symmetric-irb-scales-best }
- **အလုပ်တာဝန်ကို ညီမျှစွာ ခွဲဝေခြင်း**: Routing လုပ်ငန်းစဉ်ကို ingress နှင့် egress leaf များအကြား အချိုးညီညီ ခွဲဝေလုပ်ဆောင်စေသည်။
- **VNI State လိုအပ်ချက် နည်းပါးခြင်း**: Egress leaf များသည် မိမိတို့နှင့် တိုက်ရိုက်ချိတ်ဆက်ထားသော local host များအတွက် VNI များနှင့် VLAN များကိုသာ သိမ်းဆည်းထားရန် လိုအပ်သောကြောင့် hardware TCAM memory အသုံးပြုမှုကို အလွန်အမင်း သက်သာစေပါသည်။
