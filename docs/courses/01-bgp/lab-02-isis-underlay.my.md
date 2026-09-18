# 🧪 Lab 02 · IS-IS Underlay ပေါ်တွင် iBGP တည်ဆောက်ခြင်း

> ✅ **Validated** on Arista cEOS 4.32.0F, 2026-08-03. ဖော်ပြထားသော output အားလုံးကို live fabric မှ တိုက်ရိုက်ဖမ်းယူထားပါသည်။

**ကြာမြင့်ချိန်:** ~၃၀ မိနစ် · **Nodes အရေအတွက်:** ၃ ခု (Lab 01 နှင့် တူညီသော topology)

လည်ပတ်နေသော BGP deployment တစ်ခု၏ အောက်ခံ IGP ကို OSPF မှ IS-IS သို့ လဲလှယ်တပ်ဆင်ပါမည် — ပြီးနောက် BGP sessions များ မည်သို့ဖြစ်သွားသည်ကို စောင့်ကြည့်လေ့လာပါမည်။

ထိုအဖြေသည် သင်ယူရမည့် အဓိကသင်ခန်းစာ ဖြစ်သည်။

---

## သင်ယူလေ့လာရမည့် အချက်များ

- EOS ပေါ်ရှိ IS-IS configuration: NET addressing၊ levels များ၊ point-to-point circuits များ
- **BGP သည် သင် မည်သည့် IGP ကို run ထားသည်ကို အဘယ်ကြောင့် လုံးဝ ဂရုမစိုက်ရသနည်း**
- IS-IS database နှင့် adjacency output များကို ဖတ်ရှုစစ်ဆေးခြင်း
- OSPF နှင့် လက်တွေ့ကွာခြားသည့် အချက်များကို သိရှိနားလည်ခြင်း

---

## ကြိုတင်လိုအပ်ချက်များ (Prerequisites)

> [!IMPORTANT]
> **အစဉ်လိုက် မှီခိုမှု လင့်ခ်**: Lab 02 သည် ဗလာ fabric အသစ်တစ်ခုမှ စတင်ခြင်း **မဟုတ်ပါ**။ ၎င်းသည် **[Lab 01 · eBGP၊ iBGP နှင့် next-hop-self](lab-01-ebgp-ibgp.md)** တွင် တည်ဆောက်ခဲ့သော လည်ပတ်နေသည့် BGP fabric ပေါ်တွင် underlay ကို တိုက်ရိုက်ပြောင်းလဲမည့် migration lab တစ်ခု ဖြစ်သည်။
> အကယ်၍ သင်သည် အစမှ စတင်လိုပါက Lab 01 ၏ အခြေအနေကို ရရှိစေရန် `labs/bgp-lab` အတွင်း `./run.sh --all` ကို ဦးစွာ run ပါ။

**[Lab 01](lab-01-ebgp-ibgp.md) ကို တည်ဆောက်ပြီး ကောင်းမွန်စွာ အလုပ်လုပ်နေရပါမည်။** ဤ lab သည် အစမှ မစတင်ဘဲ ရှိပြီးသား lab ကို ပြင်ဆင်မွမ်းမံခြင်း ဖြစ်သည် — ၎င်းမှာ ရည်ရွယ်ချက်ရှိရှိ ပြုလုပ်ထားခြင်း ဖြစ်သည်။ အောက်ခံ IGP ကို လဲလှယ်ရန်အတွက် လည်ပတ်နေသော BGP deployment တစ်ခု ရှိနေရန် လိုအပ်သည်။

အခြေခံသဘောတရားများ: **[Phase 0 · IS-IS](../00-igp-fundamentals/03-isis.md)**။

!!! tip "အမြန်စတင်ရန် လမ်းညွှန် (တည်နေရာ: `labs/bgp-lab/`)"
    **အဆင့် ၁ · Lab Fabric ကို စတင်လည်ပတ်ပါ (မ run ရသေးပါက)**
    ```bash
    cd labs/bgp-lab
    sudo containerlab deploy -t topology.clab.yml --max-workers 1
    ```

    **အဆင့် ၂ · သီးသန့် Lab 02 Walkthrough ကို စတင်ပါ**
    ```bash
    ./run.sh --lab02
    ```
    *(မှတ်ချက်: `./run.sh --lab02` သည် စတင်ရန် လိုအပ်သော BGP sessions များ established ဖြစ်မဖြစ်ကို အလိုအလျောက် စစ်ဆေးပေးသည်; မဖြစ်သေးပါက IS-IS migration မစတင်မီ လိုအပ်သော အခြေအနေကို အလိုအလျောက် ပြင်ဆင်ပေးပါလိမ့်မည်!)*

---

## အဆင့် ၁ · မူလစတင်သည့် အခြေအနေကို အတည်ပြုခြင်း

Lab 01 အပြီးတွင် r1 နှင့် r2 အကြား OSPF လည်ပတ်နေပြီး iBGP peer ဖွဲ့ထားသော loopbacks များကို သယ်ဆောင်ပေးထားသည်။

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" | tail -3
```

```
  Neighbor  V AS           MsgRcvd   MsgSent  InQ OutQ  Up/Down State   PfxRcd PfxAcc
  2.2.2.2   4 65001             61        63    0    0 00:46:00 Estab   1      1
  10.0.13.3 4 65002             60        57    0    0 00:46:18 Estab   1      1
```

**`Up/Down` column ကို သေချာမှတ်သားထားပါ။** Lab အဆုံးတွင် ၎င်းကို ပြန်လည်ကြည့်ရှုပါမည်။

✅ Sessions နှစ်ခုစလုံး `Estab` ဖြစ်နေပါက **ပြီးမြောက်ပါပြီ**။

---

## အဆင့် ၂ · OSPF နေရာတွင် IS-IS ဖြင့် အစားထိုးခြင်း

=== "r1"

    ```
    configure
    no router ospf 1
    !
    router isis CORE
     net 49.0001.0000.0000.0001.00
     is-type level-2
     address-family ipv4 unicast
    !
    interface Loopback0
     isis enable CORE
     isis passive
    !
    interface Ethernet1
     isis enable CORE
     isis network point-to-point
    ```

=== "r2"

    ```
    configure
    no router ospf 1
    !
    router isis CORE
     net 49.0001.0000.0002.00
     is-type level-2
     address-family ipv4 unicast
    !
    interface Loopback0
     isis enable CORE
     isis passive
    !
    interface Ethernet1
     isis enable CORE
     isis network point-to-point
    ```

အမြဲတစေ ပြုလုပ်သည့်အတိုင်း `docker exec -i` ဖြင့် ထည့်သွင်းပါ။

**NET လိပ်စာ** `49.0001.0000.0000.0001.00` ကို ဖတ်ရှုလေ့လာခြင်း -

| အစိတ်အပိုင်း | တန်ဖိုး | အဓိပ္ပာယ် |
|---|---|---|
| AFI | `49` | Private addressing — RFC 1918 နှင့် သဘောတရားတူညီသည် |
| Area | `0001` | Interface တစ်ခုစီအတွက် မဟုတ်ဘဲ **Router တစ်ခုလုံးနှင့်** သက်ဆိုင်သည် |
| System ID | `0000.0000.0001` | ထူးခြားသီးသန့်ဖြစ်ပြီး တိတိကျကျ 6 bytes ရှိသည် |
| NSEL | `00` | Router တစ်ခုအတွက် အမြဲတမ်း `00` ဖြစ်သည် |

!!! tip "OSPF နှင့် ကွဲပြားသော Configuration အချက် ၃ ချက်"
    **Interface ပေါ်တွင် `isis enable CORE` ပေးရခြင်း**၊ Area statement မဟုတ်ပါ — Area သည် NET လိပ်စာမှ လာခြင်းဖြစ်ပြီး IS-IS တွင် *Router* သည် area ထဲတွင် ပါဝင်သောကြောင့် ဖြစ်သည်။

    **Loopback ပေါ်တွင် `isis passive` ပေးရခြင်း**၊ Area ထဲ ထည့်သွင်းခြင်း မဟုတ်ပါ။ OSPF ၏ passive-interface နှင့် ရည်ရွယ်ချက်တူညီသည်: Prefix ကို ကြေညာပေးပါ၊ ၎င်းပေါ်တွင် adjacencies မဖွဲ့ပါနှင့်။

    **`is-type level-2`** — Single-area network တစ်ခုသည် L2-only ဖြစ်သင့်သည်။ မူလ default ဖြစ်သော L1/L2 သည် router တိုင်းအား အကျိုးမရှိဘဲ database နှစ်ခု ထိန်းသိမ်းစေသည်။

---

## အဆင့် ၃ · Adjacency ကို စစ်ဆေးအတည်ပြုခြင်း

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show isis neighbors"
```

```
Instance  VRF      System Id  Type Interface   SNPA  State Hold time  Circuit Id
CORE      default  r2         L2   Ethernet1   P2P   UP    22         35
```

`State UP`၊ `Type L2`၊ `P2P`။ System Id တွင် မူလ `0000.0000.0002` အစား **`r2`** ဟု ပေါ်နေသည်ကို သတိပြုပါ — IS-IS သည် dynamic hostname TLV ကို သယ်ဆောင်ထားသဖြင့် output ကို လူသားများ ဖတ်ရှုရ လွယ်ကူစေသည်။ Router IDs များကို လက်ဖြင့် လိုက်လံတိုက်ဆိုင်နေရသော OSPF တွင် မပါရှိသည့် အလွန်ကောင်းမွန်သော အချက်တစ်ခု ဖြစ်သည်။

✅ State သည် `UP` ဖြစ်နေပါက **ပြီးမြောက်ပါပြီ**။

မဖြစ်သေးပါက- Router နှစ်ခုစလုံးတွင် link ပေါ်၌ `isis enable` ပေးထားခြင်း ရှိမရှိ၊ System IDs များ unique ဖြစ်မဖြစ်နှင့် နှစ်ဖက်စလုံးတွင် `is-type` ကိုက်ညီခြင်း ရှိမရှိ စစ်ဆေးပါ။

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show isis interface brief"
```

```
Interface Level IPv4 Metric IPv6 Metric Type            Adjacency
--------- ----- ----------- ----------- --------------- ---------
Loopback0 L2             10          10 loopback        (passive)
Ethernet1 L2             10          10 point-to-point          1
```

Loopback သည် `(passive)` ဖြစ်နေသည် — ကြေညာထားပြီး adjacencies မရှိပါ။ ရည်ရွယ်ထားသည့်အတိုင်း အတိအကျ ဖြစ်သည်။

---

## အဆင့် ၄ · Database ကို စစ်ဆေးခြင်း

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show isis database"
```

```
  IS-IS Level 2 Link State Database
    LSPID       Seq Num  Cksum  Life Length IS  Received LSPID        Flags
    r1.00-00          2  41626  1174     93 L2  0000.0000.0001.00-00  <>
    r2.00-00          2  64871  1174     93 L2  0000.0000.0002.00-00  <>
```

Router တစ်ခုလျှင် **LSP** တစ်ခုစီ ရှိသည် — OSPF ၏ router LSA နှင့် တူညီသော်လည်း LSP တစ်ခုတည်းက ထို router ကြေညာလိုသမျှကို TLVs အဖြစ် အပြည့်အစုံ သယ်ဆောင်ထားသည်။ OSPF ကမူ တူညီသော အချက်အလက်များကို LSA အမျိုးအစားများစွာအဖြစ် ခွဲခြမ်းထားသည်။

`Seq Num` သည် ပြောင်းလဲမှုရှိတိုင်း တိုးတက်လာပြီး `Life` သည် အချိန်ပြောင်းပြန် ရေတွက်ကာ refresh ပြန်ဖြစ်နေသည်။ OSPF နှင့် တူညီသော သဘောတရားဖြစ်ပြီး ထုပ်ပိုးပုံသာ ကွဲပြားခြင်း ဖြစ်သည်။

`Received LSPID` column သည် dynamic hostname နှင့်အတူ မူလ system ID ကို ယှဉ်တွဲပြသပေးသည်။

---

## အဆင့် ၅ · Routes များကို စစ်ဆေးခြင်း

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip route 2.2.2.2"
```

```
 I L2     2.2.2.2/32 [115/20]
           via 10.0.12.2, Ethernet1
```

**`I L2`** — IS-IS၊ Level 2 ဖြစ်သည်။ **`[115/20]`** — Administrative distance 115၊ Metric 20 ဖြစ်သည်။

| | OSPF | IS-IS |
|---|---|---|
| Administrative distance | 110 | **115** |
| Default interface metric | Bandwidth ပေါ်မှ တွက်ချက်သည် | **ပုံသေ 10 (Flat)** |

အောက်ပါ အချက် ၂ ချက် ထွက်ပေါ်လာသည်- **နှစ်ခုလုံး run ထားပါက AD အရ OSPF က အနိုင်ရမည်**။ ထို့ပြင် **IS-IS metrics များသည် default အားဖြင့် bandwidth ပေါ်မူတည်၍ ပြောင်းလဲခြင်း မရှိပါ** — သင်ကိုယ်တိုင် မသတ်မှတ်မချင်း interface တိုင်းသည် 10 ဖြစ်နေမည်ဖြစ်ရာ 1G နှင့် 100G link တို့သည် တူညီနေမည် ဖြစ်သည်။ Metrics များကို ရည်ရွယ်ချက်ရှိရှိ သတ်မှတ်ပေးပါ။

✅ `2.2.2.2/32` သည် `I L2` မှတစ်ဆင့် ပေါ်နေပါက **ပြီးမြောက်ပါပြီ**။

---

## အဆင့် ၆ · အဓိက သင်ခန်းစာ

ယခု BGP အခြေအနေကို ပြန်လည်ကြည့်ရှုပါ -

```bash
docker exec clab-bgp-lab-r1 Cli -p 15 -c "show ip bgp summary" | tail -3
```

```
  Neighbor  V AS           MsgRcvd   MsgSent  InQ OutQ  Up/Down State   PfxRcd PfxAcc
  2.2.2.2   4 65001             61        63    0    0 00:46:00 Estab   1      1
  10.0.13.3 4 65002             60        57    0    0 00:46:18 Estab   1      1
```

**BGP sessions များ လုံးဝ မပြုတ်ကျခဲ့ပါ။** `Up/Down` တွင် ၄၆ မိနစ်ဟု ဆက်လက်ပြသနေသည် — IGP တစ်ခုလုံးကို လဲလှယ်တပ်ဆင်ခဲ့သည့် အချိန်တစ်ခုလုံးကို ကျော်လွန်၍ ဆက်လက်အသက်ရှင်နေဆဲ ဖြစ်သည်။ လည်ပတ်နေသော BGP deployment တစ်ခု၏ အောက်ခြေမှ OSPF ကို ဖယ်ရှားပြီး IS-IS ဖြင့် အစားထိုးခဲ့သော်လည်း BGP sessions များက သတိပင်မထားမိခဲ့ပေ။

```bash
docker exec clab-bgp-lab-r2 Cli -p 15 -c "ping 172.16.30.1 source 172.16.20.1 repeat 3"
```

```
--- 172.16.30.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 11ms
```

Forwarding ဆက်လက်အလုပ်လုပ်နေဆဲ ဖြစ်သည်။ ✅ **ပြီးမြောက်ပါပြီ။**

!!! tip "ဤအရာသည် အဘယ်ကြောင့် အလုပ်ဖြစ်ရသနည်း၊ အဘယ်ကြောင့် အရေးပါသနည်း"
    **BGP သည် ၎င်း၏ peer loopback ဆီသို့ route တစ်ခု ရှိနေရန်သာ လိုအပ်သည်။ ထို route မည်သည့်နေရာမှ ရောက်လာသည်ကို BGP က လုံးဝ ဂရုမစိုက်ပါ။** OSPF မှလာသည်ဖြစ်စေ၊ IS-IS မှလာသည်ဖြစ်စေ သို့မဟုတ် static route ဖြစ်စေ — BGP သည် routing table ထဲတွင် next hop ကို resolve လုပ်ပြီး ကျန်အရာများကို ဘာမှ ထပ်မံ မမေးမြန်းပေ။

    IGP အစားထိုးမှုသည် ၁၈၀ စက္ကန့်ရှိသော BGP hold timer ထက် များစွာ ပိုမိုလျင်မြန်စွာ ပြီးဆုံးသွားခဲ့သဖြင့် BGP က peer သေဆုံးသွားပြီဟု ဘယ်တော့မှ မသတ်မှတ်ခဲ့ခြင်း ဖြစ်သည်။

    ဤအချက်ကြောင့်ပင် လက်တွေ့လည်ပတ်နေသော ကွန်ရက်ကြီးများတွင် IGP migrations များကို အောင်မြင်စွာ လုပ်ဆောင်နိုင်ခြင်း ဖြစ်သည်: Network layers များသည် အမှန်တကယ် သီးခြားစီ လွတ်လပ်စွာ ရပ်တည်နေကြသည်။ ထို့အပြင် "BGP down နေသည်" ဟူသော ပြဿနာများသည် အောက်ခြေ IGP ပြဿနာ ဖြစ်နေတတ်ရသည့် အကြောင်းရင်းလည်း ဖြစ်သည် — မှီခိုမှုမှာ အစစ်အမှန်ဖြစ်ပြီး လားရာလမ်းကြောင်း တစ်ခုတည်းသာ သက်ရောက်ခြင်း ဖြစ်သည်။

---

## ချို့ယွင်းချက် ဖန်တီး၍ စောင့်ကြည့်လေ့လာခြင်း (Break & observe)

r2 ပေါ်ရှိ IS-IS ထဲမှ loopback ကို ဖယ်ရှားလိုက်ပြီး ချို့ယွင်းချက်သည် အထက်သို့ မည်သို့ ကူးစက်သွားသည်ကို စောင့်ကြည့်ပါ -

```bash
docker exec -i clab-bgp-lab-r2 Cli -p 15 <<'EOF'
configure
interface Loopback0
 no isis enable CORE
end
EOF
```

မိနစ်အနည်းငယ်အတွင်း r1 သည် `2.2.2.2` ဆီသို့ route ပျောက်ဆုံးသွားမည်ဖြစ်ပြီး iBGP peer IP ဆီသို့ မရောက်ရှိနိုင်တော့သဖြင့် session သည် `Active` သို့ ကျဆင်းသွားပါမည် — တည်ဆောက်၍မရသော TCP ကို ထပ်ခါတလဲလဲ ကြိုးစားနေသောကြောင့် `Idle` မဟုတ်ဘဲ `Active` ဖြစ်နေခြင်း ဖြစ်သည်။

**ရောဂါလက္ခဏာမှာ "BGP ပြုတ်ကျနေခြင်း" ဖြစ်သည်။ အမှန်တကယ် ချို့ယွင်းချက်မှာ Interface တစ်ခု IGP ထဲတွင် ကျန်ခဲ့ခြင်း ဖြစ်သည်။**
[Phase 0](../00-igp-fundamentals/01-link-state.md) တွင် ဖော်ပြခဲ့သော စံပုံစံအတိုင်း အတိအကျ ဖြစ်သည်။

ပြန်လည် ထည့်သွင်းပါ -

```bash
docker exec -i clab-bgp-lab-r2 Cli -p 15 <<'EOF'
configure
interface Loopback0
 isis enable CORE
end
EOF
```

---

## ဤ Lab တွင် Configure ပြုလုပ်ခဲ့သော OSPF နှင့် IS-IS နှိုင်းယှဉ်ချက်

| | OSPF | IS-IS |
|---|---|---|
| Area အဖွဲ့ဝင်ဖြစ်မှု | **Interface** တစ်ခုစီအလိုက် (`ip ospf area`) | **Router** တစ်ခုလုံးအလိုက် (NET မှတစ်ဆင့်) |
| Link ပေါ်တွင် Enable လုပ်ခြင်း | `ip ospf area 0.0.0.0` | `isis enable CORE` |
| Loopback | `ip ospf area` + passive | `isis passive` |
| သတင်းလွှာ ကြေညာချက် | LSA အမျိုးအစားပေါင်းများစွာ | TLVs ပါဝင်သော LSP တစ်ခု |
| Neighbour ဖော်ပြချက် | Router IDs များ | **Hostnames များ** |
| Admin distance | 110 | 115 |
| Default metric | Bandwidth မှ တွက်ချက်သည် | ပုံသေ 10 |

မည်သည့် protocol မျှ ပိုမိုမခက်ခဲပါ။ IS-IS သည် addressing (NET) ကို ရှေ့ပြေးစီစဉ်ရပြီး interfaces များကို ရိုးရှင်းစေသည်; OSPF တွင် addressing သီးခြားစီစဉ်စရာမလိုသော်လည်း interface တစ်ခုချင်းစီအလိုက် configuration ပိုမိုများပြားသည်။

မည်သည့်အရာကို ရွေးချယ်သင့်သည်ကို [Phase 0 · ရွေးချယ်မှု လမ်းညွှန်](../00-igp-fundamentals/04-choosing.md) တွင် ကြည့်ရှုပါ။

---

## ပြဿနာဖြေရှင်းခြင်း လမ်းညွှန် (Troubleshooting)

| ရောဂါလက္ခဏာ | ဖြစ်ပွားရသည့် အကြောင်းရင်း |
|---|---|
| Adjacency မရှိခြင်း | တစ်ဖက်တွင် `isis enable` ကျန်ခဲ့ခြင်း သို့မဟုတ် `is-type` မကိုက်ညီခြင်း |
| Adjacency up ဖြစ်သော်လည်း routes မရှိခြင်း | `router isis` အောက်တွင် `address-family ipv4 unicast` မပါရှိခြင်း |
| Loopback ကို မကြေညာခြင်း | `isis passive` ကျန်ခဲ့ခြင်း — Lab 01 ၏ OSPF ထောင်ချောက်နှင့် သဘောတရားတူညီသည် |
| System ID တူညီနေခြင်း | Router နှစ်ခုတွင် တူညီသော NET ဖြစ်နေခြင်း — Database ထဲတွင် conflicts ရှိမရှိ စစ်ဆေးပါ |
| အပြောင်းအလဲပြီးနောက် BGP ပြုတ်ကျသွားခြင်း | ၁၈၀ စက္ကန့် hold time မကုန်မီ IGP က converge မဖြစ်နိုင်ခဲ့ခြင်း |

---

## အင်တာဗျူး မေးခွန်းများ (Interview questions)

??? question "လည်ပတ်နေသော BGP deployment တစ်ခုအောက်ရှိ IGP ကို migrate ပြုလုပ်ပါက BGP sessions များ ပြုတ်ကျမည်လား။"
    IGP အသစ်သည် BGP hold time (Default အားဖြင့် ၁၈၀ စက္ကန့်) အတွင်း converge ဖြစ်ပါက ပြုတ်မကျနိုင်ပါ။ BGP သည် peer loopback ဆီသို့ route တစ်ခု ရှိနေရန်သာ လိုအပ်ပြီး မည်သည့် protocol က install လုပ်ပေးသည်ကို ဂရုမစိုက်ပါ။ ဤ lab တွင် လက်တွေ့စစ်ဆေးခဲ့ပြီးဖြစ်သည်: OSPF မှ IS-IS သို့ လဲလှယ်စဉ် BGP sessions များသည် ၄၆ မိနစ်တိုင်တိုင် မပြတ်တောက်ဘဲ ဆက်လက်တည်ရှိနေခဲ့သည်။

??? question "IS-IS interface configuration သည် OSPF နှင့် မည်သို့ ကွဲပြားသနည်း။"
    OSPF သည် interface တစ်ခုစီကို area သို့ သတ်မှတ်ပေးရသည် (`ip ospf area 0.0.0.0`)။ IS-IS သည် router ၏ NET မှ area ကို ရယူထားပြီးဖြစ်သောကြောင့် interface ပေါ်တွင် `isis enable` သာ ပေးရန် လိုအပ်သည်။ Loopbacks များအတွက် area ပေါင်း passive-interface အစား `isis passive` ကို အသုံးပြုသည်။

??? question "IS-IS ၏ Administrative Distance မှာ မည်မျှနည်း၊ အဘယ်ကြောင့် အရေးပါသနည်း။"
    OSPF ၏ 110 နှင့် ယှဉ်ပါက 115 ဖြစ်သည်။ အကယ်၍ prefix တစ်ခုတည်းအတွက် နှစ်မျိုးစလုံး run ထားပါက **OSPF က အနိုင်ရပါမည်** — Protocols နှစ်ခုစလုံး ခေတ္တ တပြိုင်နက် run ထားရသော migration ကာလအတွင်း ဤအချက်သည် အလွန်အရေးပါပြီး ကြိုတင်မစီစဉ်ထားပါက လမ်းကြောင်းလွဲမှားမှုများ ဖြစ်စေနိုင်သည်။

??? question "Default IS-IS metric သည် အဘယ်ကြောင့် ပြဿနာဖြစ်စေသနည်း။"
    Bandwidth မည်မျှပင်ရှိစေကာမူ interface တိုင်းအတွက် ပုံသေ 10 သာ ဖြစ်နေသောကြောင့် 1G နှင့် 100G link တို့သည် မခွဲခြားနိုင်အောင် တူညီနေပေလိမ့်မည်။ OSPF ကမူ bandwidth ပေါ်မူတည်၍ cost ကို တွက်ချက်ပေးသည်။ IS-IS metrics များကို ကိုယ်တိုင် သတ်မှတ်ပေးပါ၊ ထို့အပြင် ကျယ်ပြန့်စွာ သတ်မှတ်နိုင်ရန် `metric-style wide` ကို အသုံးပြုပါ။

??? question "Neighbours များသည် System IDs အစား Hostnames များကို ပြသနေသည်။ မည်သို့ ပြုလုပ်ထားသနည်း။"
    Dynamic hostname TLV ကြောင့် ဖြစ်သည် — IS-IS သည် router ၏ hostname ကို system ID နှင့်အတူ ကြေညာပေးပြီး output က ၎င်းကို ဖတ်ရှုပြသပေးသည်။ ၎င်းသည် TLV encoding ၏ စွမ်းဆောင်ရည် အကျိုးကျေးဇူးတစ်ခုဖြစ်ပြီး OSPF တွင်မူ မပါရှိသဖြင့် router IDs များကို လက်ဖြင့် လိုက်လံတိုက်ဆိုင်နေရသည်။

---

## 🧠 Google Network Infra ဗဟုသုတ မျှဝေခြင်း

> [!NOTE]
> ### Production Deep Dive & Hyperscale Architecture
>
> 1. **Hyperscalers များသည် OSPF ထက် IS-IS ကို အဘယ်ကြောင့် ပိုမိုနှစ်သက်ကြသနည်း**:
>    - **Transport Layer**: IS-IS သည် Layer 2 Ethernet frames (`802.3` / LLC `0xFEFE`) ပေါ်တွင် တိုက်ရိုက် run သည်။ OSPF မှာမူ IP (Protocol 89) ပေါ်တွင် run ရသည်။ IP stack ချို့ယွင်းမှု သို့မဟုတ် IP interface configuration အမှားများသည် IS-IS adjacencies များကို ပြုတ်ကျမသွားစေနိုင်ပါ။
>    - **Dual-Stack ရိုးရှင်းမှု**: IS-IS process တစ်ခုတည်းနှင့် TLV extensions များဖြင့် IPv4 နှင့် IPv6 နှစ်မျိုးစလုံးကို တပြိုင်နက် ထောက်ပံ့နိုင်သည် (`multi-topology` သို့မဟုတ် `single-topology`)။ OSPF တွင်မူ သီးခြား protocol instances နှစ်ခု (IPv4 အတွက် OSPFv2၊ IPv6 အတွက် OSPFv3) run ရသည်။
>
> 2. **ဝန်ဆောင်မှု မပြတ်တောက်စေသော Underlay Cutover မဟာဗျူဟာ (Hitless Underlay Cutover Strategy)**:
>    - Production ကွန်ရက်များတွင် IGP migrations ပြုလုပ်ရာတွင် (ဥပမာ OSPF → IS-IS) BGP ၏ default 180-second hold timer နှင့် TCP ၏ ကြံ့ခိုင်မှုကို အသုံးချကြသည်။
>    - Loopback reachability သည် ၁၈၀ စက္ကန့်အတွင်း OSPF မှ IS-IS သို့ ကူးပြောင်းနိုင်သရွေ့ iBGP TCP sessions များသည် control plane routes များ မဆုံးရှုံးဘဲ၊ forwarding tables များကို မရှင်းလင်းရဘဲ established အတိုင်း ဆက်လက်တည်ရှိနေမည် ဖြစ်သည်။
>
> 3. **Wide Metrics နှင့် Traffic Engineering**:
>    - Narrow IS-IS metrics (Default 6-bit link cost, max 63) သည် ကြီးမားသော fabric များတစ်လျှောက် path engineering ပြုလုပ်ရန် ကန့်သတ်ချက်များ ရှိသည်။ Hyperscale စံနှုန်းများသည် တိကျသော traffic engineering နှင့် Segment Routing (SR-MPLS) ပြုလုပ်နိုင်ရန်အတွက် `metric-style wide` (24-bit link metrics, 32-bit path metrics) ကို မဖြစ်မနေ အသုံးပြုကြသည်။

---

## စမ်းသပ်ခန်း အပြီးသတ် သိမ်းဆည်းခြင်း (Clean up)

```bash
sudo containerlab destroy -t topology.clab.yml
```

---

**နောက်တစ်ခု:** [Lab 03 · Route Reflectors များ →](lab-03-route-reflectors.md)
