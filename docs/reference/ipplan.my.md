# IP လိပ်စာခွဲဝေမှု အစီအစဉ် (IP Addressing Plan) {: #ip-addressing-plan }

Lab တိုင်းတွင် အသုံးပြုသော စံနှုန်းသတ်မှတ် အစီအစဉ် ဖြစ်ပါသည်။ **အကယ်၍ configuration တစ်ခုခုသည် ဤစာရွက်စာတမ်းနှင့် ကွဲလွဲနေပါက၊ ဤစာရွက်စာတမ်းကသာ အတည်ဖြစ်သည် — configuration ကို ပြင်ဆင်ပါ။**

ဤ scheme သည် ဖတ်ရှုရ လွယ်ကူစေရန် တမင်တကာ စနစ်တကျ ရေးဆွဲထားခြင်း ဖြစ်သည်: မည်သည့် interface IP ကိုမဆို ကြည့်ရုံဖြင့် မည်သည့်စက်နှင့် မည်သည့် link ဖြစ်ကြောင်း ချက်ချင်း သိရှိနိုင်ပါသည်။

---

## စက်ပစ္စည်း ID များ (Device IDs) {: #device-ids }

စက်တစ်ခုစီတွင် ၎င်း၏ loopback ၏ နောက်ဆုံး octet အဖြစ် အသုံးပြုသော ဂဏန်း ID တစ်ခုစီ ရှိပါသည်။

| စက်ပစ္စည်း  | ID | အခန်းကဏ္ဍ | AS (overlay) |
|---------|----|-------|--------------|
| spine1  | 11 | spine | — (transport သာလျှင်) |
| spine2  | 12 | spine | — (transport သာလျှင်) |
| leaf1   | 21 | leaf  | 65000 |
| leaf2   | 22 | leaf  | 65000 |

စံသတ်မှတ်ချက်: Spine များအတွက် `1X`၊ Leaf များအတွက် `2X`။ Leaf အသစ်များ ထပ်တိုးပါက 23, 24, … အဖြစ် ဆက်လက်သတ်မှတ်မည်။

## Loopback — `lo0.0` {: #loopback-lo0-0 }

> **Juniper vs Cisco မှတ်ချက်:** Cisco စံနှုန်းတွင် loopback *နှစ်ခု* သုံးခဲ့သည် (loopback0 = router-id, loopback1 = VTEP source)။ Junos တွင်မူ အရာအားလုံးအတွက် loopback **တစ်ခုတည်း** ကိုသာ သုံးပါသည် — router-id၊ OSPF/BGP source၊ နှင့် `set switch-options vtep-source-interface lo0.0` မှတစ်ဆင့် VTEP source အဖြစ် သုံးသည်။ Junos EVPN-VXLAN တွင် ဤပုံစံသည် ပိုမိုရိုးရှင်းပြီး standard ဖြစ်ပါသည်။

| စက်ပစ္စည်း  | lo0.0         | အသုံးပြုမှု |
|---------|---------------|---------|
| spine1  | 10.0.0.11/32  | router-id, OSPF |
| spine2  | 10.0.0.12/32  | router-id, OSPF |
| leaf1   | 10.0.0.21/32  | router-id, OSPF, BGP peer, **VTEP source** |
| leaf2   | 10.0.0.22/32  | router-id, OSPF, BGP peer, **VTEP source** |

## P2P Underlay Links (`/31`) {: #p2p-underlay-links }

နံပါတ်ပေးပုံစံ: `10.10.<link-id>.0/31`။ Spine ဘက်ခြမ်းသည် အမြဲ `.0` ဖြစ်ပြီး Leaf ဘက်ခြမ်းသည် အမြဲ `.1` ဖြစ်သည်။

| Link | Subnet        | Spine ဘက်ခြမ်း   | Leaf ဘက်ခြမ်း   |
|------|---------------|------------------|-----------------|
| 1    | 10.10.1.0/31  | spine1 (.0)      | leaf1 (.1)      |
| 2    | 10.10.2.0/31  | spine1 (.0)      | leaf2 (.1)      |
| 3    | 10.10.3.0/31  | spine2 (.0)      | leaf1 (.1)      |
| 4    | 10.10.4.0/31  | spine2 (.0)      | leaf2 (.1)      |

## Interface ချိတ်ဆက်မှု (containerlab ↔ Junos) {: #interface-mapping }

> **Config မစတင်မီ ဖတ်ရှုပါ:** `topology.clab.yml` တွင် containerlab က ဖော်ပြသော `ethN` အမည်များကို cable ချိတ်ဆက်ရသည်။ vJunos *အတွင်းပိုင်းတွင်* ၎င်းတို့သည် Junos interface အမည်များအဖြစ် သတ်မှတ်သည်။ Config များနှင့် `steps/` များတွင် **Junos** အမည်များကိုသာ အသုံးပြုသည်။
>
> ✅ **vJunos-switch 23.2R1.14 ပေါ်တွင် စမ်းသပ်အတည်ပြုပြီး**။ **+1 offset** ကို သတိပြုပါ: clab `ethN` → `ge-0/0/(N-1)`။

| clab endpoint | Junos interface | ရည်ရွယ်ချက် |
|---------------|-----------------|---------|
| `eth1`        | `ge-0/0/0`      | spine1 သို့ uplink (leaves) / leaf1 သို့ downlink (spines) |
| `eth2`        | `ge-0/0/1`      | spine2 သို့ uplink (leaves) / leaf2 သို့ downlink (spines) |
| `eth3`        | `ge-0/0/2`      | host ဘက်သို့ access port (leaves) |
| `eth4`        | `ge-0/0/3`      | reserved (peer-link, နောက်ပိုင်း lab များအတွက်) |

> `show interfaces terse` တွင် တွေ့ရသော `ge-0/0/N.16386` sub-unit များသည် vJunos ၏ internal သာဖြစ်ပြီး လျစ်လျူရှုနိုင်ပါသည်။

## Management (fxp0) — သတိပြုရန် {: #management-fxp0 }

vJunos management (`fxp0`) သည် **10.0.0.0/24** ပေါ်တွင် တည်ရှိပြီး၊ အောက်ပါ loopback range နှင့် *ထပ်တူကျနေပါသည်*။ ၎င်းတို့သည် **သီးခြား routing instance** များတွင် တည်ရှိနေသောကြောင့် (`fxp0` အတွက် `mgmt_junos.inet.0`၊ loopback များအတွက် `inet.0`) လုပ်ဆောင်ချက်အရ မည်သည့် conflict မှ မဖြစ်ပေါ်ပါ — သို့သော် ရှုပ်ထွေးမှု ဖြစ်စေနိုင်ပါသည်။ အကယ်၍ ရှုပ်ထွေးမှုဖြစ်ပါက loopback များကို `10.255.0.X/32` သို့ ပြောင်းလဲခြင်း သို့မဟုတ် topology ထဲတွင် မထပ်သော `mgmt` subnet သတ်မှတ်နိုင်ပါသည်။

## အကောင့် အထောက်အထားများ (Credentials) {: #credentials }

`juniper_vjunosswitch` အတွက် default အကောင့်:
**user `admin` / password `admin@123`** (script များထဲရှိ `LAB_USER`/`LAB_PASS` နှင့် ကိုက်ညီသည်)။

## Host ချိတ်ဆက်သော Port များ (Leaves သာလျှင်) {: #host-facing-ports }

| စက်ပစ္စည်း | clab port | ချိတ်ဆက်ထားသော စက် |
|--------|-----------|-------------|
| leaf1  | eth3      | host1       |
| leaf2  | eth3      | host2       |

## Tenant လိပ်စာ အပိုင်းအခြားများ (Underlay တွင် လုံးဝမပေါ်ပါ) {: #tenant-address-spaces }

Fabric အတွင်း EVPN route များအဖြစ်သာ သယ်ဆောင်သည်။

| VLAN | VNI (L2) | Subnet          | ရည်ရွယ်ချက်        |
|------|----------|-----------------|--------------------|
| 100  | 10100    | 10.100.10.0/24  | Tenant-A web tier  |

| Host  | IP (VLAN 100)   |
|-------|-----------------|
| host1 | 10.100.10.10/24 |
| host2 | 10.100.10.11/24 |

## VNI အစီအစဉ် {: #vni-plan }

| အမျိုးအစား | VNI   | ချိတ်ဆက်မှု     |
|-------|-------|---------------|
| L2VNI | 10100 | VLAN 100      |
| L3VNI | 50001 | (နောက်ပိုင်း lab များ) |

စံသတ်မှတ်ချက်: L2VNI = `10000 + VLAN`၊ L3VNI = `50000 + tenant index`။ ၎င်းသည် `show` output တွင် VNI သည် L2 လား L3 လား ချက်ချင်း သိသာစေပါသည်။

## Overlay ဒီဇိုင်း — lab 01 (iBGP full mesh) {: #overlay-design-lab-01 }

- **VTEP အားလုံးသည် AS 65000 တွင် တည်ရှိသည်။**
- **Leaves များသည် အချင်းချင်း loopback-to-loopback peer ပြုလုပ်ကြသည်** (true full mesh)။ Leaf ၂ လုံးတွင် single iBGP-EVPN session တစ်ခုသာ လိုအပ်သည်။
- **Spines များသည် underlay OSPF ကိုသာ run သည်** — ၎င်းတို့သည် IP packet များကို forward လုပ်ရုံသာဖြစ်ပြီး EVPN ကို မ run သလို VXLAN tunnel များကိုလည်း terminate မလုပ်ပါ။

```
        spine1        spine2         ← OSPF သာလျှင်၊ EVPN မပါပါ
        /    \        /    \
    leaf1 ───┼────────┼─── leaf2
        └──────iBGP-EVPN──────┘       ← session တစ်ခုတည်း၊ lo0-to-lo0
```
